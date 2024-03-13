package config

import (
	"fmt"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/storage"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	"path"
	"path/filepath"
)

const (
	EnvironmentDev  Environment = "dev"
	EnvironmentTest Environment = "test"
	EnvironmentProd Environment = "prod"

	DefaultEnvPath = "config/.env"

	EnvPath       EnvironmentVariable = "ENV_PATH"
	ConfigPath    EnvironmentVariable = "CONFIG_PATH"
	FileStorePath EnvironmentVariable = "FILESTORE_PATH"
	DBPassword    EnvironmentVariable = "DB_PASSWORD"
)

// LoadEnv finds the appropriate env file to use for the service
// and configures the environment with the configured input file.
func LoadEnv() (string, error) {
	envVarPath := viper.GetString(EnvPath.String())

	dir, file := path.Split(envVarPath)
	envFilePath := filepath.Join(dir, file)
	logrus.Infof("loading config from env path: %s", envFilePath)

	viper.SetConfigType("env")
	viper.SetConfigName(".env")
	viper.SetConfigFile(envFilePath)

	if err := viper.ReadInConfig(); err != nil {
		return "", errors.Wrap(err, "error reading viper config")
	}

	return envFilePath, nil
}

func validateEnv(config *SSIServiceConfig) error {

	dbPassword := env.GetString(DBPassword.String())
	if dbPassword != "" {
		if len(config.Services.StorageOptions) != 0 {
			for _, storageOption := range config.Services.StorageOptions {
				if storageOption.ID == storage.PasswordOption {
					storageOption.Option = dbPassword
					break
				}
			}
		}
	}

	filestorePath := env.GetString(FileStorePath.String())
	if filestorePath != "" {
		config.Services.FileStoreConfig.LocalPath = filestorePath
	} else if config.Server.Service == ServiceResourceowner {
		return fmt.Errorf("filestore path must be set by env var [%s] for ServiceID %s", FileStorePath.String(), config.Server.Service)
	}

	return nil
}
