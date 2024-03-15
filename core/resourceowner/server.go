package resourceowner

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/schema"
	"github.com/ethereum/go-ethereum/ethclient"
	configpkg "github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/log"
	framework "github.com/fapiper/onchain-access-control/core/server/framework"
	"github.com/fapiper/onchain-access-control/core/server/middleware"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/fapiper/onchain-access-control/core/service/rpc/ipfs"
	"github.com/gin-gonic/gin"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"net/http"
)

func Run() {
	engine := Init()
	addr := fmt.Sprintf(":%s", env.GetString("PORT"))
	err := http.ListenAndServe(addr, engine)
	if err != nil {
		logrus.WithError(err).Errorf(err.Error())
	}
}

// Init does two things: instantiate all services and register their HTTP bindings
func Init() *gin.Engine {
	SetDefaults()

	config := configpkg.Init()
	log.Init(config.Server.LogLevel, config.Server.LogLocation)

	ctx := context.Background()
	clients := ClientInit(ctx)
	i, err := ServicesInit(ctx, clients, config.Services)
	if err != nil {
		logrus.WithError(err).Error(err.Error())
	}

	engine, err := CoreInit(ctx, *config, i)
	if err != nil {
		logrus.WithError(err).Error(err.Error())
	}

	return engine
}

type Clients struct {
	HTTPClient *http.Client
	EthClient  *ethclient.Client
	IPFSClient *shell.Shell
}

func ClientInit(ctx context.Context) *Clients {
	return &Clients{
		HTTPClient: &http.Client{Timeout: 0},
		EthClient:  rpc.NewEthClient(),
		IPFSClient: ipfs.NewShell(),
	}
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

func SetDefaults() {
	viper.SetDefault("ENV_PATH", "")
	viper.SetDefault("CONFIG_PATH", "")
	viper.SetDefault("ENV", "dev")
	viper.SetDefault("PORT", 4001)
	viper.SetDefault("IPFS_URL", "https://cloudflare-ipfs.com/ipfs")
	viper.SetDefault("REDIS_URL", "localhost:6379")
	viper.SetDefault("RPC_URL", "https://eth-sepolia.g.alchemy.com/v2/demo")
	viper.SetDefault("PRIVATE_KEY", "")
	viper.SetDefault("CONTEXT_HANDLER_CONTRACT", "")
	viper.SetDefault("INFURA_API_KEY", "")
	viper.SetDefault("INFURA_API_SECRET", "")
	viper.SetDefault("KEYSTORE_PASSWORD", "default-keystore-password")
	viper.SetDefault("DB_PASSWORD", "default-db-password")
	viper.SetDefault("USE_AUTH_TOKEN", true)
	viper.SetDefault("FILESTORE_PATH", "./static")

	viper.AutomaticEnv()
}
