package framework

import (
	"context"
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/otel/trace"
	"net/http"
	"os"
)

const (
	serviceName string = "onchain-access-control"
)

// Server is the entrypoint into our application and what configures our context object for each of our http router.
// Feel free to add any configuration data/logic on this Server struct.
type Server struct {
	*http.Server
	router      *gin.Engine
	tracer      trace.Tracer
	shutdown    chan os.Signal
	preShutdown []func(ctx context.Context) error
}

// RegisterPreShutdownHook registers a possibly blocking function to be run before Shutdown is called.
func (s *Server) RegisterPreShutdownHook(f func(_ context.Context) error) {
	s.preShutdown = append(s.preShutdown, f)
}

// PreShutdownHooks runs all hooks that were registered by calling RegisterPreShutdownHook.
func (s *Server) PreShutdownHooks(ctx context.Context) error {
	for _, f := range s.preShutdown {
		if err := f(ctx); err != nil {
			logrus.WithError(err).Warnf("pre shutdown hook error")
			return err
		}
	}
	return nil
}

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
