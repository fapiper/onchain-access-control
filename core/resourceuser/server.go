// Package resourceuser contains handler functions and routes for a data consumer
package resourceuser

import (
	"context"
	"github.com/TBD54566975/ssi-sdk/schema"
	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/log"
	"github.com/fapiper/onchain-access-control/core/server/framework"
	"github.com/fapiper/onchain-access-control/core/server/middleware"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"net/http"
)

// Init does two things: instantiates all service and registers their HTTP bindings
func Init() {

	config := configpkg.Init()
	log.Init(config.Server.LogLevel, config.Server.LogLocation)

	ctx := context.Background()
	instance, _ := servicesInit(ctx, config.Services)
	engine, _ := CoreInit(ctx, *config, instance)

	http.Handle("/", engine)
}

// CoreInit initializes core server functionality. This is abstracted
// so the test server can also utilize it
func CoreInit(ctx context.Context, config configpkg.SSIServiceConfig, instance *Service) (*gin.Engine, error) {
	engine := framework.SetupEngine(ctx, config.Server)

	// set up engine and middleware
	middlewares := gin.HandlersChain{
		gin.Recovery(),
		gin.Logger(),
		middleware.ErrLogger(),
	}
	if config.Server.JagerEnabled {
		middlewares = append(middlewares, otelgin.Middleware(configpkg.ServiceName))
	}
	if config.Server.EnableAllowAllCORS {
		middlewares = append(middlewares, middleware.CORS())
	}

	engine.Use(middlewares...)

	// setup schema caching based on config
	if config.Server.EnableSchemaCaching {
		localSchemas, err := schema.GetAllLocalSchemas()
		if err != nil {
			logrus.WithError(err).Error("could not load local schemas")
		} else {
			cl, err := schema.NewCachingLoader(localSchemas)
			if err != nil {
				logrus.WithError(err).Error("could not create caching loader")
			}
			cl.EnableHTTPCache()
		}
	}

	return handlersInit(ctx, config, instance, engine)
}
