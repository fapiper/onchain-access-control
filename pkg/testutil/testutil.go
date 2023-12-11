package testutil

import (
	didsdk "github.com/TBD54566975/ssi-sdk/did"
	miniredis "github.com/alicebob/miniredis/v2"
	"github.com/fapiper/onchain-access-control/config"
	"github.com/fapiper/onchain-access-control/pkg/service/auth"
	"github.com/fapiper/onchain-access-control/pkg/service/did"
	"github.com/fapiper/onchain-access-control/pkg/service/keystore"
	"github.com/fapiper/onchain-access-control/pkg/storage"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"os"
	"testing"
)

var TestDatabases = []struct {
	Name           string
	ServiceStorage func(t *testing.T) storage.ServiceStorage
}{
	{
		Name:           "Test with Bolt DB",
		ServiceStorage: setupBoltTestDB,
	},
	{
		Name:           "Test with Redis DB",
		ServiceStorage: setupRedisTestDB,
	},
}

func setupBoltTestDB(t *testing.T) storage.ServiceStorage {
	file, err := os.CreateTemp("", "bolt")
	require.NoError(t, err)
	name := file.Name()
	err = file.Close()
	require.NoError(t, err)
	s, err := storage.NewStorage(storage.Bolt, storage.Option{
		ID:     storage.BoltDBFilePathOption,
		Option: name,
	})

	require.NoError(t, err)

	t.Cleanup(func() {
		_ = s.Close()
		_ = os.Remove(s.URI())
	})

	return s
}

func setupRedisTestDB(t *testing.T) storage.ServiceStorage {
	server := miniredis.RunT(t)
	options := []storage.Option{
		{
			ID:     storage.RedisAddressOption,
			Option: server.Addr(),
		},
		{
			ID:     storage.PasswordOption,
			Option: "test-password",
		},
	}
	s, err := storage.NewStorage(storage.Redis, options...)
	require.NoError(t, err)

	t.Cleanup(func() {
		_ = s.Close()
	})

	return s
}

func CreateTestAuthService(t *testing.T) (*auth.Service, error) {
	file, err := os.CreateTemp("", "bolt")
	require.NoError(t, err)
	name := file.Name()
	assert.NoError(t, file.Close())
	s, err := storage.NewStorage(storage.Bolt, storage.Option{
		ID:     storage.BoltDBFilePathOption,
		Option: name,
	})
	assert.NoError(t, err)
	assert.NotEmpty(t, s)

	// remove the db file after the test
	t.Cleanup(func() {
		_ = s.Close()
		_ = os.Remove(s.URI())
	})

	servicesConfig := new(config.ServicesConfig)
	servicesConfig.DIDConfig.Methods = []string{didsdk.KeyMethod.String()}

	keyEncrypter, keyDecrypter, err := keystore.NewServiceEncryption(s, servicesConfig.KeyStoreConfig.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	require.NoError(t, err)
	require.NotEmpty(t, keyEncrypter, keyDecrypter)

	keyStoreServiceFactory := keystore.NewKeyStoreServiceFactory(servicesConfig.KeyStoreConfig, s, keyEncrypter, keyDecrypter)
	require.NotEmpty(t, keyStoreServiceFactory)

	keyStoreService, err := keyStoreServiceFactory(s)
	require.NoError(t, err)
	require.NotEmpty(t, keyStoreService)

	didService, err := did.NewDIDService(servicesConfig.DIDConfig, s, keyStoreService, keyStoreServiceFactory)
	require.NoError(t, err)
	require.NotEmpty(t, didService)

	didResolver := didService.GetResolver()
	require.NotEmpty(t, didResolver)

	return auth.NewAuthService(servicesConfig.AuthConfig, s, didResolver, keyStoreService)
}
