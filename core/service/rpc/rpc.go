package rpc

import (
	"context"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
	"github.com/fapiper/onchain-access-control/core/env"
	"net"
	"net/http"
	"strings"
	"time"
)

func init() {
	// env.RegisterValidation("IPFS_URL", "required")
	// env.RegisterValidation("FALLBACK_IPFS_URL", "required")
}

const (
	defaultHTTPKeepAlive           = 600
	defaultHTTPMaxIdleConns        = 250
	defaultHTTPMaxIdleConnsPerHost = 250
	GethSocketOpName               = "geth.wss"
)

var (
	defaultHTTPClient = newHTTPClientForRPC()
)

// rateLimited is the content returned from an RPC call when rate limited.
var rateLimited = "429 Too Many Requests"

type ErrEthClient struct {
	Err error
}

func (e ErrEthClient) Error() string {
	return e.Err.Error()
}

// NewEthClient returns an ethclient.Client
func NewEthClient() *ethclient.Client {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var client *rpc.Client
	var err error

	if endpoint := env.GetString("RPC_URL"); strings.HasPrefix(endpoint, "https://") {
		client, err = rpc.DialHTTPWithClient(endpoint, defaultHTTPClient)
		if err != nil {
			panic(err)
		}
	} else {
		client, err = rpc.DialContext(ctx, endpoint)
		if err != nil {
			panic(err)
		}
	}

	return ethclient.NewClient(client)
}

// newHTTPClientForRPC returns a http.Client configured with default settings intended for RPC calls.
func newHTTPClientForRPC() *http.Client {
	return &http.Client{
		Timeout: 0,
		Transport: &http.Transport{
			Dial:                (&net.Dialer{KeepAlive: defaultHTTPKeepAlive * time.Second}).Dial,
			MaxIdleConns:        defaultHTTPMaxIdleConns,
			MaxIdleConnsPerHost: defaultHTTPMaxIdleConnsPerHost,
		},
	}
}
