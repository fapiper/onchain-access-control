package config

import (
	"expvar"
	"github.com/ardanlabs/conf"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"os"
)

const (
	DefaultConfigPath = ""
	Filename          = "dev.toml"
	Extension         = ".toml"

	ServiceResourceuser  ServiceID = "resourceuser"
	ServiceResourceowner ServiceID = "resourceowner"
	ServiceIssuer        ServiceID = "issuer"
)

func Init() *OACServiceConfig {
	_, err := LoadEnv()
	if err != nil {
		logrus.Fatalf("could not instantiate env: %s", err.Error())
	}

	cfg, err := LoadConfig()
	if err != nil {
		logrus.Fatalf("could not instantiate config: %s", err.Error())
	}

	// make sure to set the api base in our service info
	SetAPIBase(cfg.Services.ServiceEndpoint)

	expvar.NewString("build").Set(ServiceVersion)

	out, err := conf.String(cfg)
	if err != nil {
		logrus.Fatalf("could not serialize config: %s", err.Error())
	}

	logrus.Infof("Config: \n%v\n", out)

	return cfg
}

// LoadConfig attempts to load a TOML config file from the given path, and coerce it into our object model.
// Before loading, defaults are applied on certain properties, which are overwritten if specified in the TOML file.
func LoadConfig() (*OACServiceConfig, error) {
	// create the config object
	config := new(OACServiceConfig)
	if err := parseConfig(config); err != nil {
		return nil, errors.Wrap(err, "parse and apply defaults")
	}

	if err := validateEnv(config); err != nil {
		return nil, errors.Wrap(err, "apply env variables")
	}

	if err := validateConfig(config); err != nil {
		return nil, errors.Wrap(err, "validating config values")
	}
	return config, nil
}

func validateConfig(s *OACServiceConfig) error {
	if s.Server.Environment == EnvironmentProd {
		if s.Services.KeyStoreConfig.DisableEncryption {
			return errors.New("prod environment cannot disable key encryption")
		}
		if s.Services.AppLevelEncryptionConfiguration.DisableEncryption {
			logrus.Warn("Prod environment detected without app level encryption. This is strongly discouraged.")
		}
	}
	return nil
}

func parseConfig(cfg *OACServiceConfig) error {
	// parse and apply defaults
	err := conf.Parse(os.Args[1:], ServiceName, cfg)
	if err == nil {
		return nil
	}
	switch {
	case errors.Is(err, conf.ErrHelpWanted):
		usage, err := conf.Usage(ServiceName, &cfg)
		if err != nil {
			return errors.Wrap(err, "parsing config")
		}
		logrus.Info(usage)

		return nil
	case errors.Is(err, conf.ErrVersionWanted):
		version, err := conf.VersionString(ServiceName, &cfg)
		if err != nil {
			return errors.Wrap(err, "generating config version")
		}

		logrus.Info(version)
		return nil
	}
	return errors.Wrap(err, "parsing config")
}
