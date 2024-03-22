package resourceowner

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/service/accesscontrol"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/pkg/errors"

	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/service/credential"
	"github.com/fapiper/onchain-access-control/core/service/did"
	frameworksvc "github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/keystore"
	"github.com/fapiper/onchain-access-control/core/service/operation"
	"github.com/fapiper/onchain-access-control/core/service/presentation"
	"github.com/fapiper/onchain-access-control/core/service/schema"
	wellknown "github.com/fapiper/onchain-access-control/core/service/well-known"
	"github.com/fapiper/onchain-access-control/core/storage"
)

// Service represents all services and their dependencies independent of transport
type Service struct {
	KeyStore         *keystore.Service
	AccessControl    *accesscontrol.Service
	RPC              *rpc.Service
	DID              *did.Service
	Schema           *schema.Service
	Credential       *credential.Service
	Presentation     *presentation.Service
	Operation        *operation.Service
	storage          storage.ServiceStorage
	BatchDID         *did.BatchService
	DIDConfiguration *wellknown.DIDConfigurationService
}

// ServicesInit creates a new instance of the resource user which instantiates all services and their
// dependencies independent of transport.
func ServicesInit(ctx context.Context, clients *Clients, config configpkg.ServicesConfig) (*Service, error) {
	if err := validateServiceConfig(config); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate SSI Service, invalid config")
	}
	return servicesInitUnsafe(clients, config)
}

func validateServiceConfig(config configpkg.ServicesConfig) error {
	if !storage.IsStorageAvailable(storage.Type(config.StorageProvider)) {
		return fmt.Errorf("%s storage provider configured, but not available", config.StorageProvider)
	}
	if config.KeyStoreConfig.IsEmpty() {
		return fmt.Errorf("%s no config provided", frameworksvc.KeyStore)
	}
	if config.DIDConfig.IsEmpty() {
		return fmt.Errorf("%s no config provided", frameworksvc.DID)
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

	didConfigurationService, err := wellknown.NewDIDConfigurationService(keyStoreService, didResolver, schemaService)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the did configuration service")
	}

	rpcService, err := rpc.NewRPCService()
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the rpc service")
	}

	accessControlServiceFactory := accesscontrol.NewAccessControlServiceFactory(storageProvider, presentationService, didResolver, keyStoreService, keyEncrypter, keyDecrypter, rpcService, c.IPFSClient)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate the access control service factory")
	}

	accessControlService, err := accessControlServiceFactory(storageProvider)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate access control service")
	}

	return &Service{
		KeyStore:         keyStoreService,
		DID:              didService,
		BatchDID:         batchDIDService,
		Schema:           schemaService,
		Credential:       credentialService,
		Presentation:     presentationService,
		Operation:        operationService,
		AccessControl:    accessControlService,
		RPC:              rpcService,
		DIDConfiguration: didConfigurationService,
		storage:          storageProvider,
	}, nil
}

// GetServices returns all services
func (s *Service) GetServices() []frameworksvc.Service {
	return []frameworksvc.Service{
		s.KeyStore,
		s.DID,
		s.Schema,
		s.Credential,
		s.Presentation,
		s.Operation,
		s.AccessControl,
	}
}

func (s *Service) GetStorage() storage.ServiceStorage {
	return s.storage
}
