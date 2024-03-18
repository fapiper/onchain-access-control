package issuer

import (
	"context"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/server/router"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginswagger "github.com/swaggo/gin-swagger"
)

const (
	HealthPrefix    = "/health"
	ReadinessPrefix = "/readiness"
	SwaggerPrefix   = "/swagger/*any"
	V1Prefix        = "/v1"
)

func handlersInit(ctx context.Context, config configpkg.SSIServiceConfig, instance *Service, engine *gin.Engine) (*gin.Engine, error) {
	engine.GET(HealthPrefix, router.Health)
	engine.GET(ReadinessPrefix, router.Readiness(instance.GetServices()))
	engine.StaticFile("swagger.yaml", "./doc/swagger.yaml")
	engine.GET(SwaggerPrefix, ginswagger.WrapHandler(swaggerfiles.Handler, ginswagger.URL("/swagger.yaml")))

	// make sure to set the api base and filestore base in our service info
	configpkg.SetAPIBase(config.Services.ServiceEndpoint)

	return apiInit(ctx, config, instance, engine)
}

func apiInit(ctx context.Context, config configpkg.SSIServiceConfig, instance *Service, engine *gin.Engine) (*gin.Engine, error) {

	v1 := engine.Group(V1Prefix)
	if err := KeyStoreAPI(v1, instance.KeyStore); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate KeyStore API")
	}
	if err := DecentralizedIdentityAPI(v1, instance.DID, instance.BatchDID, instance.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate DID API")
	}
	if err := CredentialAPI(v1, instance.Credential, instance.Webhook, config.Services.StatusEndpoint); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Credential API")
	}
	if err := OperationAPI(v1, instance.Operation); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Operation API")
	}
	if err := PresentationAPI(v1, instance.Presentation, instance.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Presentation API")
	}
	if err := ManifestAPI(v1, instance.Manifest, instance.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Manifest API")
	}
	if err := WebhookAPI(v1, instance.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Webhook API")
	}
	if err := DIDConfigurationAPI(v1, instance.DIDConfiguration); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate DIDConfiguration API")
	}

	return engine, nil
}
