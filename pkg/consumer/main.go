package consumer

import (
	"context"
	"expvar"
	"io"
	"os"
	"os/signal"
	"path"
	"strconv"
	"syscall"
	"time"

	"github.com/TBD54566975/ssi-sdk/schema"
	"github.com/ardanlabs/conf"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"

	"github.com/fapiper/onchain-access-control/config"
)

func Init() {
	logrus.Info("Starting up...")

	if err := run(); err != nil {
		logrus.Fatalf("main: error: %s", err.Error())
	}
}

// startup and shutdown logic
func run() error {
	configPath := config.DefaultConfigPath
	envConfigPath, present := os.LookupEnv(config.ConfigPath.String())
	if present {
		logrus.Infof("loading config from env var path: %s", envConfigPath)
		configPath = envConfigPath
	}

	dir, file := path.Split(configPath)
	cfg, err := config.LoadConfig(file, os.DirFS(dir))
	if err != nil {
		logrus.Fatalf("could not instantiate config: %s", err.Error())
	}

	// set up logger
	if logFile := configureLogger(cfg.Server.LogLevel, cfg.Server.LogLocation); logFile != nil {
		defer func(logFile *os.File) {
			if err = logFile.Close(); err != nil {
				logrus.WithError(err).Error("failed to close log file")
			}
		}(logFile)
	}

	// set up schema caching based on config
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

	consumerServer, err := NewServer(shutdown, *cfg)
	if err != nil {
		logrus.Fatalf("could not start http services: %s", err.Error())
	}

	serverErrors := make(chan error, 1)
	go func() {
		logrus.Infof("main: server started and listening on -> %s", consumerServer.Server.Addr)
		serverErrors <- consumerServer.ListenAndServe()
	}()

	select {
	case err = <-serverErrors:
		return errors.Wrap(err, "server error")
	case sig := <-shutdown:
		logrus.Infof("main: shutdown signal received -> %v", sig)

		ctx, cancel := context.WithTimeout(context.Background(), cfg.Server.ShutdownTimeout)
		defer cancel()

		if err := consumerServer.PreShutdownHooks(ctx); err != nil {
			logrus.WithError(err).Error("main: failed to run pre shutdown hooks")
		}

		if err = consumerServer.Shutdown(ctx); err != nil {
			logrus.WithError(err).Error("main: failed to stop server gracefully, forcing shutdown")
			if err = consumerServer.Close(); err != nil {
				logrus.WithError(err).Error("main: failed to close server")
			}
		}
	}

	return nil
}

// configureLogger configures the logger to logs to the given location and returns a file pointer to a logs
// file that should be closed upon server shutdown
func configureLogger(level, location string) *os.File {
	if level != "" {
		logLevel, err := logrus.ParseLevel(level)
		if err != nil {
			logrus.WithError(err).Errorf("could not parse log level<%s>, setting to info", level)
			logrus.SetLevel(logrus.InfoLevel)
		} else {
			logrus.SetLevel(logLevel)
		}
	}

	logrus.SetFormatter(&logrus.JSONFormatter{
		DisableTimestamp: false,
		PrettyPrint:      true,
	})
	logrus.SetReportCaller(true)

	// set logs config from config file
	now := time.Now()
	logrus.SetOutput(os.Stdout)
	if location != "" {
		logFile := location + "/" + config.ServiceName + "-" + now.Format(time.DateOnly) + "-" + strconv.FormatInt(now.Unix(), 10) + ".log"
		file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
		if err != nil {
			logrus.WithError(err).Warn("failed to create logs file, using default stdout")
		} else {
			mw := io.MultiWriter(os.Stdout, file)
			logrus.SetOutput(mw)
		}
		return file
	}
	return nil
}
