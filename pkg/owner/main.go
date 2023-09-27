package owner

import (
	"context"
	"expvar"
	"github.com/TBD54566975/ssi-sdk/schema"
	"github.com/ardanlabs/conf"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"os"
	"os/signal"
	"syscall"

	"github.com/fapiper/onchain-access-control/config"
	"github.com/fapiper/onchain-access-control/log"
)

func Init() {
	logrus.Info("Starting up...")

	if err := run(); err != nil {
		logrus.Fatalf("main: error: %s", err.Error())
	}
}

// startup and shutdown logic
func run() error {
	// init config
	cfg := config.Init()

	// setup logger based on config
	if logFile := log.Init(cfg.Server.LogLevel, cfg.Server.LogLocation); logFile != nil {
		defer func(logFile *os.File) {
			if err := logFile.Close(); err != nil {
				logrus.WithError(err).Error("failed to close log file")
			}
		}(logFile)
	}

	// setup schema caching based on config
	if cfg.Server.EnableSchemaCaching {
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

	expvar.NewString("build").Set(config.ServiceVersion)

	logrus.Infof("main: Started : Service initializing : env [%s] : version %q", cfg.Server.Environment, config.ServiceVersion)
	defer logrus.Info("main: Completed")

	out, err := conf.String(cfg)
	if err != nil {
		return errors.Wrap(err, "serializing config")
	}

	logrus.Infof("main: Config: \n%v\n", out)

	// create a channel of buffer size 1 to handle shutdown.
	// buffer's size is 1 in order to ignore any additional ctrl+c
	// spamming.
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

	server, err := NewServer(shutdown, *cfg)

	if err != nil {
		logrus.Fatalf("could not start http services: %s", err.Error())
	}

	serverErrors := make(chan error, 1)
	go func() {
		logrus.Infof("main: pkg.server started and listening on -> %s", server.Server.Addr)
		serverErrors <- server.ListenAndServe()
	}()

	select {
	case err = <-serverErrors:
		return errors.Wrap(err, "pkg.server error")
	case sig := <-shutdown:
		logrus.Infof("main: shutdown signal received -> %v", sig)

		ctx, cancel := context.WithTimeout(context.Background(), cfg.Server.ShutdownTimeout)
		defer cancel()

		if err := server.PreShutdownHooks(ctx); err != nil {
			logrus.WithError(err).Error("main: failed to run pre shutdown hooks")
		}

		if err = server.Shutdown(ctx); err != nil {
			logrus.WithError(err).Error("main: failed to stop pkg.server gracefully, forcing shutdown")
			if err = server.Close(); err != nil {
				logrus.WithError(err).Error("main: failed to close pkg.server")
			}
		}
	}

	return nil
}
