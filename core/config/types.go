package config

import (
	"github.com/fapiper/onchain-access-control/core/storage"
	"reflect"
	"time"
)

type (
	Environment         string
	ServiceID           string
	EnvironmentVariable string
)

func (e EnvironmentVariable) String() string {
	return string(e)
}

type SSIServiceConfig struct {
	Server   ServerConfig   `toml:"server"`
	Services ServicesConfig `toml:"services"`
}

// ServerConfig represents configurable properties for the HTTP server
type ServerConfig struct {
	Environment         Environment   `toml:"env" conf:"default:dev"`
	Service             ServiceID     `toml:"service" conf:"default:resourceuser"`
	APIHost             string        `toml:"api_host" conf:"default:0.0.0.0:3000"`
	JagerHost           string        `toml:"jager_host" conf:"default:http://jaeger:14268/api/traces"`
	JagerEnabled        bool          `toml:"jager_enabled" conf:"default:false"`
	ReadTimeout         time.Duration `toml:"read_timeout" conf:"default:5s"`
	WriteTimeout        time.Duration `toml:"write_timeout" conf:"default:5s"`
	ShutdownTimeout     time.Duration `toml:"shutdown_timeout" conf:"default:5s"`
	LogLocation         string        `toml:"log_location" conf:"default:log"`
	LogLevel            string        `toml:"log_level" conf:"default:debug"`
	EnableSchemaCaching bool          `toml:"enable_schema_caching" conf:"default:true"`
	EnableAllowAllCORS  bool          `toml:"enable_allow_all_cors" conf:"default:false"`
}

// ServicesConfig represents configurable properties for the components of the SSI Service
type ServicesConfig struct {
	// at present, it is assumed that a single storage provider works for all services
	// in the future it may make sense to have per-service storage providers (e.g. mysql for one service,
	// mongo for another)
	StorageProvider string           `toml:"storage" conf:"default:bolt"`
	StorageOptions  []storage.Option `toml:"storage_option"`
	ServiceEndpoint string           `toml:"service_endpoint" conf:"default:http://localhost:8080"`
	StatusEndpoint  string           `toml:"status_endpoint"`

	// Application level encryption configuration. Defines how values are encrypted before they are stored in the
	// configured KV store.
	AppLevelEncryptionConfiguration EncryptionConfig `toml:"storage_encryption,omitempty"`

	// Embed all service-specific configs here. The order matters: from which should be instantiated first, to last
	AuthConfig       AuthServiceConfig       `toml:"auth,omitempty"`
	KeyStoreConfig   KeyStoreServiceConfig   `toml:"keystore,omitempty"`
	FileStoreConfig  FileStoreServiceConfig  `toml:"filestore,omitempty"`
	DIDConfig        DIDServiceConfig        `toml:"did,omitempty"`
	CredentialConfig CredentialServiceConfig `toml:"credential,omitempty"`
}

type AuthServiceConfig struct {
	EncryptionConfig
}

type KeyStoreServiceConfig struct {
	EncryptionConfig
}

type EncryptionConfig struct {
	DisableEncryption bool `toml:"disable_encryption" conf:"default:false"`

	// The URI for a master key. We use tink for envelope encryption as described in https://github.com/google/tink/blob/9bc2667963e20eb42611b7581e570f0dddf65a2b/docs/KEY-MANAGEMENT.md#key-management-with-tink
	// When left empty and DisableEncryption is off, then a random key is generated and used. This random key is persisted unencrypted in the
	// configured storage. Production deployments should never leave this field empty.
	MasterKeyURI string `toml:"master_key_uri"`

	// Path for credentials. Required when MasterKeyURI is set. More info at https://github.com/google/tink/blob/9bc2667963e20eb42611b7581e570f0dddf65a2b/docs/KEY-MANAGEMENT.md#credentials
	KMSCredentialsPath string `toml:"kms_credentials_path"`
}

func (e EncryptionConfig) GetMasterKeyURI() string {
	return e.MasterKeyURI
}

func (e EncryptionConfig) GetKMSCredentialsPath() string {
	return e.KMSCredentialsPath
}

func (e EncryptionConfig) EncryptionEnabled() bool {
	return !e.DisableEncryption
}

func (k *KeyStoreServiceConfig) IsEmpty() bool {
	if k == nil {
		return true
	}
	// this returns false since reflection will fail on the EncryptionConfig struct
	return false
}

func (k *KeyStoreServiceConfig) GetMasterKeyURI() string {
	return k.MasterKeyURI
}

func (k *KeyStoreServiceConfig) GetKMSCredentialsPath() string {
	return k.KMSCredentialsPath
}

func (k *KeyStoreServiceConfig) EncryptionEnabled() bool {
	return !k.DisableEncryption
}

type FileStoreServiceConfig struct {
	// Path to static files. WIll be set by environment variable. Required.
	LocalPath string `toml:"local_path"`

	// Server entrypoint for directory listing.
	EndpointPrefix string `toml:"endpoint_prefix" conf:"default:static"`
}

type DIDServiceConfig struct {
	Methods                  []string `toml:"methods" conf:"default:key;web"`
	LocalResolutionMethods   []string `toml:"local_resolution_methods" conf:"default:key;peer;web;jwk;pkh"`
	UniversalResolverURL     string   `toml:"universal_resolver_url"`
	UniversalResolverMethods []string `toml:"universal_resolver_methods"`
	IONResolverURL           string   `toml:"ion_resolver_url"`
	// BatchCreateMaxItems set's the maximum amount that can be.
	BatchCreateMaxItems int `toml:"batch_create_max_items" conf:"default:100"`
}

func (d *DIDServiceConfig) IsEmpty() bool {
	if d == nil {
		return true
	}
	return reflect.DeepEqual(d, &DIDServiceConfig{})
}

type CredentialServiceConfig struct {
	// BatchCreateMaxItems set's the maximum amount of credentials that can be created in a single request.
	BatchCreateMaxItems int `toml:"batch_create_max_items" conf:"default:100"`
	// BatchUpdateStatusMaxItems set's the maximum amount of credentials statuses that can be updated in a single request.
	BatchUpdateStatusMaxItems int `toml:"batch_update_status_max_items" conf:"default:100"`

	// TODO(gabe) supported key and signature types
}

func (c *CredentialServiceConfig) IsEmpty() bool {
	if c == nil {
		return true
	}
	return reflect.DeepEqual(c, &CredentialServiceConfig{})
}
