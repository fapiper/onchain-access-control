package rpc

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"io/fs"
	"net"
	"net/http"
	"os"
	"path/filepath"
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

type GrantRoleParams struct {
	roleId        [32]byte
	did           [32]byte
	policyContext [32]byte
	policyId      [32]byte
	args          []byte
}

// GrantRole grants a role to a user
func GrantRole(ctx context.Context, txOpts *bind.TransactOpts, ethClient *ethclient.Client, address persist.Address, params GrantRoleParams) (*types.Transaction, error) {
	contract := address.Address()

	instance, err := contracts.NewAccessContext(contract, ethClient)
	if err != nil {
		return nil, err
	}

	tx, err := instance.GrantRole(txOpts, params.roleId, params.did, [][32]byte{params.policyContext}, [][32]byte{params.policyContext}, [][]byte{params.args})
	if err != nil {
		return nil, err
	}

	return tx, nil
}

// newHTTPClientForRPC returns a http.Client configured with default settings intended for RPC calls.
func newHTTPClientForRPC() *http.Client {
	// get x509 cert pool
	pool, err := x509.SystemCertPool()
	if err != nil {
		panic(err)
	}

	// walk every file in the tls directory and add them to the cert pool
	filepath.WalkDir("root-certs", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		bs, err := os.ReadFile(path)
		if err != nil {
			return err
		}

		// append cert to pool
		ok := pool.AppendCertsFromPEM(bs)
		if !ok {
			return fmt.Errorf("failed to append cert to pool")
		}
		return nil
	})

	return &http.Client{
		Timeout: 0,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs: pool,
			},
			Dial:                (&net.Dialer{KeepAlive: defaultHTTPKeepAlive * time.Second}).Dial,
			MaxIdleConns:        defaultHTTPMaxIdleConns,
			MaxIdleConnsPerHost: defaultHTTPMaxIdleConnsPerHost,
		},
	}
}
