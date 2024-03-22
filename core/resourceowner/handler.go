package resourceowner

import (
	"context"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/server/middleware"
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
	configpkg.SetFileStoreBase(config.Services.FileStoreConfig.EndpointPrefix)

	// data router with auth
	data := engine.Group(configpkg.GetFileStoreBase())

	data.Use(middleware.AuthMiddleware(instance.AccessControl))
	data.StaticFS("/", gin.Dir(config.Services.FileStoreConfig.LocalPath, false))

	return apiInit(ctx, config, instance, engine)
}

func apiInit(ctx context.Context, config configpkg.SSIServiceConfig, instance *Service, engine *gin.Engine) (*gin.Engine, error) {

	// register all v1 routers
	v1 := engine.Group(V1Prefix)
	if err := AccessControlAPI(v1, instance.AccessControl); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Access API")
	}
	if err := KeyStoreAPI(v1, instance.KeyStore); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate KeyStore API")
	}
	if err := DecentralizedIdentityAPI(v1, instance.DID, instance.BatchDID); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate DID API")
	}
	if err := CredentialAPI(v1, instance.Credential, config.Services.StatusEndpoint); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Credential API")
	}
	if err := OperationAPI(v1, instance.Operation); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Operation API")
	}
	if err := PresentationAPI(v1, instance.Presentation); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Presentation API")
	}

	return engine, nil
}
