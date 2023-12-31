package owner

import (
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/pkg/service/auth"
	"github.com/pkg/errors"

	"github.com/fapiper/onchain-access-control/config"
	"github.com/fapiper/onchain-access-control/pkg/service/credential"
	"github.com/fapiper/onchain-access-control/pkg/service/did"
	"github.com/fapiper/onchain-access-control/pkg/service/framework"
	"github.com/fapiper/onchain-access-control/pkg/service/keystore"
	"github.com/fapiper/onchain-access-control/pkg/service/operation"
	"github.com/fapiper/onchain-access-control/pkg/service/presentation"
	"github.com/fapiper/onchain-access-control/pkg/service/schema"
	"github.com/fapiper/onchain-access-control/pkg/service/webhook"
	wellknown "github.com/fapiper/onchain-access-control/pkg/service/well-known"
	"github.com/fapiper/onchain-access-control/pkg/storage"
)

// Service represents all services and their dependencies independent of transport
type Service struct {
	KeyStore         *keystore.Service
	Auth             *auth.Service
	DID              *did.Service
	Schema           *schema.Service // TODO seperate service into SchemaRead and SchemaWrite
	Credential       *credential.Service
	Presentation     *presentation.Service
	Operation        *operation.Service
	Webhook          *webhook.Service
	storage          storage.ServiceStorage
	BatchDID         *did.BatchService
	DIDConfiguration *wellknown.DIDConfigurationService
}

// instantiateService creates a new instance of the Consumers which instantiates all services and their
// dependencies independent of transport.
func instantiateService(config config.ServicesConfig) (*Service, error) {
	if err := validateServiceConfig(config); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate SSI Service, invalid config")
	}
	service, err := instantiateServices(config)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not instantiate the ssi service")
	}
	return service, nil
}

func validateServiceConfig(config config.ServicesConfig) error {
	if !storage.IsStorageAvailable(storage.Type(config.StorageProvider)) {
		return fmt.Errorf("%s storage provider configured, but not available", config.StorageProvider)
	}
	if config.KeyStoreConfig.IsEmpty() {
		return fmt.Errorf("%s no config provided", framework.KeyStore)
	}
	if config.DIDConfig.IsEmpty() {
		return fmt.Errorf("%s no config provided", framework.DID)
	}
	if config.WebhookConfig.IsEmpty() {
		return fmt.Errorf("%s no config provided", framework.Webhook)
	}
	return nil
}

// instantiateServices begins all instantiates and their dependencies
func instantiateServices(config config.ServicesConfig) (*Service, error) {

	unencryptedStorageProvider, err := storage.NewStorage(storage.Type(config.StorageProvider), config.StorageOptions...)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not instantiate storage provider: %s", config.StorageProvider)
	}

	storageEncrypter, storageDecrypter, err := keystore.NewServiceEncryption(unencryptedStorageProvider, config.AppLevelEncryptionConfiguration, keystore.ServiceDataEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating app level encrypter")
	}
	storageProvider := unencryptedStorageProvider
	if storageEncrypter != nil && storageDecrypter != nil {
		storageProvider = storage.NewEncryptedWrapper(unencryptedStorageProvider, storageEncrypter, storageDecrypter)
	}

	webhookService, err := webhook.NewWebhookService(config.WebhookConfig, storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the webhook service")
	}

	keyEncrypter, keyDecrypter, err := keystore.NewServiceEncryption(unencryptedStorageProvider, config.KeyStoreConfig.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating keystore encrypter")
	}
	keyStoreServiceFactory := keystore.NewKeyStoreServiceFactory(config.KeyStoreConfig, storageProvider, keyEncrypter, keyDecrypter)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the keystore service factory")
	}

	keyStoreService, err := keyStoreServiceFactory(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate KeyStore service")
	}

	batchDIDService, err := did.NewBatchDIDService(config.DIDConfig, storageProvider, keyStoreServiceFactory)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate batch DID service")
	}

	didService, err := did.NewDIDService(config.DIDConfig, storageProvider, keyStoreService, keyStoreServiceFactory)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the DID service")
	}
	didResolver := didService.GetResolver()

	schemaService, err := schema.NewSchemaService(storageProvider, keyStoreService, didResolver)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the schema service")
	}

	credentialService, err := credential.NewCredentialService(config.CredentialConfig, storageProvider, keyStoreService, didResolver, schemaService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the credential service")
	}

	presentationService, err := presentation.NewPresentationService(storageProvider, didResolver, schemaService, keyStoreService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the presentation service")
	}

	operationService, err := operation.NewOperationService(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the operation service")
	}

	didConfigurationService, _ := wellknown.NewDIDConfigurationService(keyStoreService, didResolver, schemaService)

	authServiceFactory := auth.NewAuthServiceFactory(storageProvider, didResolver, keyStoreService, keyEncrypter, keyDecrypter)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the auth service factory")
	}

	authService, err := authServiceFactory(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate Auth service")
	}

	return &Service{
		KeyStore:         keyStoreService,
		Auth:             authService,
		DID:              didService,
		BatchDID:         batchDIDService,
		Schema:           schemaService,
		Credential:       credentialService,
		Presentation:     presentationService,
		Operation:        operationService,
		Webhook:          webhookService,
		DIDConfiguration: didConfigurationService,
		storage:          storageProvider,
	}, nil
}

// GetServices returns all services
func (s *Service) GetServices() []framework.Service {
	return []framework.Service{
		s.KeyStore,
		s.Auth,
		s.DID,
		s.Schema,
		s.Credential,
		s.Presentation,
		s.Operation,
		s.Webhook,
	}
}

func (s *Service) GetStorage() storage.ServiceStorage {
	return s.storage
}
