package rpc

import (
	"context"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
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
	defaultHTTPClient     = newHTTPClientForRPC(true)
	defaultMetricsHandler = metricsHandler{}
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

type GrantRoleParams struct {
	roleId        [32]byte
	did           [32]byte
	policyContext [32]byte
	policyId      [32]byte
	args          [32]byte
}

// GrantRole grants a role to a user
func GrantRole(ctx context.Context, txOpts *bind.TransactOpts, ethClient *ethclient.Client, address persist.Address, params GrantRoleParams) (*types.Transaction, error) {
	contract := address.Address()

	instance, err := contracts.NewAccessContext(contract, ethClient)
	if err != nil {
		return nil, err
	}

	tx, err := instance.GrantRole(txOpts, params.roleId, params.did, params.policyContext, params.policyContext, params.args)
	if err != nil {
		return nil, err
	}

	return tx, nil
}
