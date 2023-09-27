package owner

import (
	"os"

	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginswagger "github.com/swaggo/gin-swagger"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"

	"github.com/fapiper/onchain-access-control/config"
	framework "github.com/fapiper/onchain-access-control/pkg/server/framework"
	"github.com/fapiper/onchain-access-control/pkg/server/handler"
	"github.com/fapiper/onchain-access-control/pkg/server/middleware"
	"github.com/fapiper/onchain-access-control/pkg/server/router"
)

const (
	HealthPrefix    = "/health"
	ReadinessPrefix = "/readiness"
	SwaggerPrefix   = "/swagger/*any"
	V1Prefix        = "/v1"
)

// Server exposes all dependencies needed to run a http server and all its services
type Server struct {
	*config.ServerConfig
	*Service
	*framework.Server
}

// NewServer does two things: instantiates all service and registers their HTTP bindings
func NewServer(shutdown chan os.Signal, cfg config.SSIServiceConfig) (*Server, error) {
	// creates an HTTP pkg.server from the framework, and wrap it to extend it for the Consumers
	engine := setUpEngine(cfg.Server, shutdown)
	httpServer := framework.NewServer(cfg.Server, engine, shutdown)
	owner, err := InstantiateService(cfg.Services)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate owner service")
	}

	// make sure to set the api base in our service info
	config.SetAPIBase(cfg.Services.ServiceEndpoint)

	// service-level routers
	engine.GET(HealthPrefix, router.Health)
	engine.GET(ReadinessPrefix, router.Readiness(owner.GetServices()))
	engine.StaticFile("swagger.yaml", "./doc/swagger.yaml")
	engine.GET(SwaggerPrefix, ginswagger.WrapHandler(swaggerfiles.Handler, ginswagger.URL("/swagger.yaml")))

	// register all v1 routers
	v1 := engine.Group(V1Prefix)
	if err = handler.KeyStoreAPI(v1, owner.KeyStore); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate KeyStore API")
	}
	if err = handler.DecentralizedIdentityAPI(v1, owner.DID, owner.BatchDID, owner.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate DID API")
	}
	if err = handler.CredentialAPI(v1, owner.Credential, owner.Webhook, cfg.Services.StatusEndpoint); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Credential API")
	}
	if err = handler.OperationAPI(v1, owner.Operation); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Operation API")
	}
	if err = handler.PresentationAPI(v1, owner.Presentation, owner.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Presentation API")
	}
	if err = handler.ManifestAPI(v1, owner.Manifest, owner.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Manifest API")
	}
	if err = handler.WebhookAPI(v1, owner.Webhook); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate Webhook API")
	}
	if err = handler.DIDConfigurationAPI(v1, owner.DIDConfiguration); err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "unable to instantiate DIDConfiguration API")
	}

	return &Server{
		Server:       httpServer,
		Service:      owner,
		ServerConfig: &cfg.Server,
	}, nil
}

// setUpEngine creates the gin engine and sets up the middleware based on config
func setUpEngine(cfg config.ServerConfig, shutdown chan os.Signal) *gin.Engine {
	gin.ForceConsoleColor()
	middlewares := gin.HandlersChain{
		gin.Recovery(),
		gin.Logger(),
		middleware.Errors(shutdown),
	}
	if cfg.JagerEnabled {
		middlewares = append(middlewares, otelgin.Middleware(config.ServiceName))
	}
	if cfg.EnableAllowAllCORS {
		middlewares = append(middlewares, middleware.CORS())
	}

	// set up engine and middleware
	engine := gin.New()
	engine.Use(middlewares...)
	switch cfg.Environment {
	case config.EnvironmentDev:
		gin.SetMode(gin.DebugMode)
	case config.EnvironmentTest:
		gin.SetMode(gin.TestMode)
	case config.EnvironmentProd:
		gin.SetMode(gin.ReleaseMode)
	}
	return engine
}
