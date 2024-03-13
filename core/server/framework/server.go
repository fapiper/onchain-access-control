package framework

import (
	"context"
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/gin-gonic/gin"
)

const (
	serviceName string = "onchain-access-control"
)

func SetupEngine(ctx context.Context, c config.ServerConfig) *gin.Engine {
	engine := gin.New()
	gin.ForceConsoleColor()

	switch c.Environment {
	case config.EnvironmentDev:
		gin.SetMode(gin.DebugMode)
	case config.EnvironmentTest:
		gin.SetMode(gin.TestMode)
	case config.EnvironmentProd:
		gin.SetMode(gin.ReleaseMode)
	}

	return engine
}
