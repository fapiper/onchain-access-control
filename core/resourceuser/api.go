package resourceuser

import (
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/gin-gonic/gin"

	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/server/router"
	didsvc "github.com/fapiper/onchain-access-control/core/service/did"
	svcframework "github.com/fapiper/onchain-access-control/core/service/framework"
)

const (
	OperationPrefix         = "/operations"
	AuthPrefix              = "/auth"
	AccessPrefix            = "/access"
	DIDsPrefix              = "/dids"
	ResolverPrefix          = "/resolver"
	SchemasPrefix           = "/schemas"
	CredentialsPrefix       = "/credentials"
	StatusPrefix            = "/status"
	PresentationsPrefix     = "/presentations"
	DefinitionsPrefix       = "/definitions"
	SubmissionsPrefix       = "/submissions"
	IssuanceTemplatePrefix  = "/issuancetemplates"
	RequestsPrefix          = "/requests"
	ManifestsPrefix         = "/manifests"
	ApplicationsPrefix      = "/applications"
	ResponsesPrefix         = "/responses"
	KeyStorePrefix          = "/keys"
	VerificationPath        = "/verification"
	DIDConfigurationsPrefix = "/did-configurations"

	batchSuffix = "/batch"
)

// KeyStoreAPI registers all HTTP handlers for the Key Store Service
func KeyStoreAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	keyStoreRouter, err := router.NewKeyStoreRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating key store router")
	}

	// make sure the keystore service is configured to use the correct path
	config.SetServicePath(svcframework.KeyStore, KeyStorePrefix)
	keyStoreAPI := rg.Group(KeyStorePrefix)
	keyStoreAPI.PUT("", keyStoreRouter.StoreKey)
	keyStoreAPI.GET("/:id", keyStoreRouter.GetKeyDetails)
	keyStoreAPI.DELETE("/:id", keyStoreRouter.RevokeKey)
	return
}

// AuthAPI registers all HTTP handlers for the Auth Service
func AuthAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	r, err := router.NewAuthRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating auth router")
	}
	api := rg.Group(AuthPrefix)
	api.PUT("/role/:id", r.GrantRole)
	// api.DELETE("/role/:id", r.RevokeRole)
	api.PUT("/session", r.StartSession)

	return
}

// DecentralizedIdentityAPI registers all HTTP handlers for the DID Service
func DecentralizedIdentityAPI(rg *gin.RouterGroup, service *didsvc.Service, did *didsvc.BatchService) (err error) {
	didRouter, err := router.NewDIDRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating DID router")
	}
	batchDIDRouter := router.NewBatchDIDRouter(did)

	// make sure the DID service is configured to use the correct path
	config.SetServicePath(svcframework.DID, DIDsPrefix)
	didAPI := rg.Group(DIDsPrefix)
	didAPI.GET("", didRouter.ListDIDMethods)
	didAPI.PUT("/:method", didRouter.CreateDIDByMethod)
	didAPI.PUT("/:method/:id", didRouter.UpdateDIDByMethod)
	didAPI.PUT("/:method/batch", batchDIDRouter.BatchCreateDIDs)
	didAPI.GET("/:method", didRouter.ListDIDsByMethod)
	didAPI.GET("/:method/:id", didRouter.GetDIDByMethod)
	didAPI.DELETE("/:method/:id", didRouter.SoftDeleteDIDByMethod)
	didAPI.GET(ResolverPrefix+"/:id", didRouter.ResolveDID)
	return
}

// SchemaAPI registers all HTTP handlers for the Schema Service
func SchemaAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	schemaRouter, err := router.NewSchemaRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating schema router")
	}

	// make sure the schema service is configured to use the correct path
	config.SetServicePath(svcframework.Schema, SchemasPrefix)
	schemaAPI := rg.Group(SchemasPrefix)
	schemaAPI.PUT("", schemaRouter.CreateSchema)
	schemaAPI.GET("/:id", schemaRouter.GetSchema)
	schemaAPI.GET("", schemaRouter.ListSchemas)
	schemaAPI.DELETE("/:id", schemaRouter.DeleteSchema)
	return
}

// CredentialAPI registers all HTTP handlers for the Credentials Service
func CredentialAPI(rg *gin.RouterGroup, service svcframework.Service, statusEndpoint string) (err error) {
	credRouter, err := router.NewCredentialRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating credential router")
	}

	// make sure the credential service is configured to use the correct path
	config.SetServicePath(svcframework.Credential, CredentialsPrefix)

	// allows for a custom URI to be used for status list credentials, if not set, we use the default path
	if statusEndpoint != "" {
		config.SetStatusBase(statusEndpoint)
	} else {
		config.SetStatusBase(fmt.Sprintf("%s/status", config.GetServicePath(svcframework.Credential)))
	}

	// Credentials
	credentialAPI := rg.Group(CredentialsPrefix)
	credentialAPI.PUT("", credRouter.CreateCredential)
	credentialAPI.PUT(batchSuffix, credRouter.BatchCreateCredentials)
	credentialAPI.GET("", credRouter.ListCredentials)
	credentialAPI.GET("/:id", credRouter.GetCredential)
	credentialAPI.PUT(VerificationPath, credRouter.VerifyCredential)
	credentialAPI.DELETE("/:id", credRouter.DeleteCredential)

	// Credential Status
	credentialAPI.GET("/:id"+StatusPrefix, credRouter.GetCredentialStatus)
	credentialAPI.PUT("/:id"+StatusPrefix, credRouter.UpdateCredentialStatus)
	credentialAPI.PUT(StatusPrefix+batchSuffix, credRouter.BatchUpdateCredentialStatus)
	credentialAPI.GET(StatusPrefix+"/:id", credRouter.GetCredentialStatusList)
	return
}

// PresentationAPI registers all HTTP handlers for the Presentation Service
func PresentationAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	presRouter, err := router.NewPresentationRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating credential router")
	}

	// make sure the presentation service is configured to use the correct path
	config.SetServicePath(svcframework.Presentation, PresentationsPrefix)

	presAPI := rg.Group(PresentationsPrefix)
	presAPI.PUT(VerificationPath, presRouter.VerifyPresentation)

	presDefAPI := rg.Group(PresentationsPrefix + DefinitionsPrefix)
	presDefAPI.PUT("", presRouter.CreateDefinition)
	presDefAPI.GET("/:id", presRouter.GetDefinition)
	presDefAPI.GET("", presRouter.ListDefinitions)
	presDefAPI.DELETE("/:id", presRouter.DeleteDefinition)

	presReqAPI := rg.Group(PresentationsPrefix + RequestsPrefix)
	presReqAPI.PUT("", presRouter.CreateRequest)
	presReqAPI.GET("/:id", presRouter.GetRequest)
	presReqAPI.GET("", presRouter.ListRequests)
	presReqAPI.PUT("/:id", presRouter.DeleteRequest)

	presSubAPI := rg.Group(PresentationsPrefix + SubmissionsPrefix)
	presSubAPI.PUT("", presRouter.CreateSubmission)
	presSubAPI.GET("/:id", presRouter.GetSubmission)
	presSubAPI.GET("", presRouter.ListSubmissions)
	presSubAPI.PUT("/:id/review", presRouter.ReviewSubmission)
	return
}

// OperationAPI registers all HTTP handlers for the Operations Service
func OperationAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	operationRouter, err := router.NewOperationRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating operation router")
	}

	// make sure the operation service is configured to use the correct path
	config.SetServicePath(svcframework.Operation, OperationPrefix)

	operationAPI := rg.Group(OperationPrefix)
	operationAPI.GET("", operationRouter.ListOperations)
	// In this case, it's used so that the operation id matches `presentations/submissions/{submission_id}` for the DIDWebID
	// path	`/v1/operations/cancel/presentations/submissions/{id}`
	operationAPI.PUT("/cancel/*id", operationRouter.CancelOperation)
	operationAPI.GET("/*id", operationRouter.GetOperation)
	return
}

// ManifestAPI registers all HTTP handlers for the Manifest Service
func ManifestAPI(rg *gin.RouterGroup, service svcframework.Service) (err error) {
	manifestRouter, err := router.NewManifestRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating manifest router")
	}

	// make sure the manifest service is configured to use the correct path
	config.SetServicePath(svcframework.Manifest, ManifestsPrefix)

	manifestAPI := rg.Group(ManifestsPrefix)
	manifestAPI.PUT("", manifestRouter.CreateManifest)
	manifestAPI.GET("", manifestRouter.ListManifests)
	manifestAPI.GET("/:id", manifestRouter.GetManifest)
	manifestAPI.DELETE("/:id", manifestRouter.DeleteManifest)

	applicationAPI := manifestAPI.Group(ApplicationsPrefix)
	applicationAPI.PUT("", manifestRouter.SubmitApplication)
	applicationAPI.GET("", manifestRouter.ListApplications)
	applicationAPI.GET("/:id", manifestRouter.GetApplication)
	applicationAPI.DELETE("/:id", manifestRouter.DeleteApplication)
	applicationAPI.PUT("/:id/review", manifestRouter.ReviewApplication)

	manifestReqAPI := manifestAPI.Group(RequestsPrefix)
	manifestReqAPI.PUT("", manifestRouter.CreateRequest)
	manifestReqAPI.GET("", manifestRouter.ListRequests)
	manifestReqAPI.GET("/:id", manifestRouter.GetRequest)
	manifestReqAPI.PUT("/:id", manifestRouter.DeleteRequest)

	responseAPI := manifestAPI.Group(ResponsesPrefix)
	responseAPI.GET("", manifestRouter.ListResponses)
	responseAPI.GET("/:id", manifestRouter.GetResponse)
	responseAPI.DELETE("/:id", manifestRouter.DeleteResponse)
	return
}

// IssuanceAPI registers all HTTP handlers for the Issuance Service
func IssuanceAPI(rg *gin.RouterGroup, service svcframework.Service) error {
	issuanceRouter, err := router.NewIssuanceRouter(service)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "creating issuing router")
	}

	// make sure the issuance service is configured to use the correct path
	config.SetServicePath(svcframework.Issuance, IssuanceTemplatePrefix)

	issuanceAPI := rg.Group(IssuanceTemplatePrefix)
	issuanceAPI.PUT("", issuanceRouter.CreateIssuanceTemplate)
	issuanceAPI.GET("", issuanceRouter.ListIssuanceTemplates)
	issuanceAPI.GET("/:id", issuanceRouter.GetIssuanceTemplate)
	issuanceAPI.DELETE("/:id", issuanceRouter.DeleteIssuanceTemplate)
	return nil
}
