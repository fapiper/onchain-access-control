package issuer

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/pkg/errors"

	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/service/credential"
	"github.com/fapiper/onchain-access-control/core/service/did"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/issuance"
	"github.com/fapiper/onchain-access-control/core/service/keystore"
	"github.com/fapiper/onchain-access-control/core/service/manifest"
	"github.com/fapiper/onchain-access-control/core/service/operation"
	"github.com/fapiper/onchain-access-control/core/service/presentation"
	"github.com/fapiper/onchain-access-control/core/service/schema"
	"github.com/fapiper/onchain-access-control/core/service/webhook"
	wellknown "github.com/fapiper/onchain-access-control/core/service/well-known"
	"github.com/fapiper/onchain-access-control/core/storage"
)

// Service represents all services and their dependencies independent of transport
type Service struct {
	KeyStore         *keystore.Service
	DID              *did.Service
	Schema           *schema.Service
	Issuance         *issuance.Service
	Credential       *credential.Service
	Manifest         *manifest.Service
	Presentation     *presentation.Service
	Operation        *operation.Service
	Webhook          *webhook.Service
	storage          storage.ServiceStorage
	BatchDID         *did.BatchService
	DIDConfiguration *wellknown.DIDConfigurationService
}

// ServicesInit creates a new instance of the issuer which instantiates all services and their
// dependencies independent of transport.
func ServicesInit(ctx context.Context, clients *Clients, config configpkg.ServicesConfig) (*Service, error) {
	if err := validateServiceConfig(config); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate issuer service, invalid config")
	}
	return servicesInitUnsafe(clients, config)
}

func validateServiceConfig(config configpkg.ServicesConfig) error {
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

// servicesInitUnsafe starts all instantiates and their dependencies without validation
func servicesInitUnsafe(c *Clients, config configpkg.ServicesConfig) (*Service, error) {
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

	issuanceService, err := issuance.NewIssuanceService(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the issuance service")
	}

	credentialService, err := credential.NewCredentialService(config.CredentialConfig, storageProvider, keyStoreService, didResolver, schemaService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the credential service")
	}

	presentationService, err := presentation.NewPresentationService(storageProvider, didResolver, schemaService, keyStoreService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the presentation service")
	}

	manifestService, err := manifest.NewManifestService(storageProvider, keyStoreService, didResolver, credentialService, presentationService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the manifest service")
	}

	operationService, err := operation.NewOperationService(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the operation service")
	}

	didConfigurationService, _ := wellknown.NewDIDConfigurationService(keyStoreService, didResolver, schemaService)
	return &Service{
		KeyStore:         keyStoreService,
		DID:              didService,
		BatchDID:         batchDIDService,
		Schema:           schemaService,
		Issuance:         issuanceService,
		Credential:       credentialService,
		Manifest:         manifestService,
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
		s.DID,
		s.Schema,
		s.Issuance,
		s.Credential,
		s.Manifest,
		s.Presentation,
		s.Operation,
		s.Webhook,
	}
}

func (s *Service) GetStorage() storage.ServiceStorage {
	return s.storage
}
