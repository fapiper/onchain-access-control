package authorize

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/fapiper/onchain-access-control/core/storage"
	"github.com/fapiper/onchain-access-control/core/tx"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/pkg/errors"
)

type Service struct {
	storageClient *Storage
	ipfsClient    *shell.Shell
	ethClient     *ethclient.Client
}

func (s Service) Type() framework.Type {
	return framework.Authorize
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.storageClient == nil {
		ae.AppendString("no storage configured")
	}
	if s.ipfsClient == nil {
		ae.AppendString("no ipfs client configured")
	}
	if s.ethClient == nil {
		ae.AppendString("no eth client configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("authorize service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func Init(s storage.ServiceStorage, ethClient *ethclient.Client, ipfsClient *shell.Shell) (*Service, error) {
	storageClient, err := NewStorage(s)

	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "instantiating storage for the authorize service")
	}

	service := Service{
		storageClient: storageClient,
		ipfsClient:    ipfsClient,
		ethClient:     ethClient,
	}
	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}

	return &service, nil
}

// GrantRole verifies a policy and assign the role.
func (s Service) GrantRole(ctx context.Context, input GrantRoleInput, txArgs tx.SendTxArgs, password string, chainID uint64) (*Role, error) {
	if !input.IsValid() {
		return nil, errors.Errorf("invalid grant role input: %+v", input)
	}

	txOpts := txArgs.ToTransactOpts("key", password, chainID)

	params := rpc.GrantRoleParams{}

	_, err := rpc.GrantRole(ctx, txOpts, s.ethClient, input.RoleContext, params)
	if err != nil {
		return nil, errors.Wrap(err, "unable to execute grant role transaction")
	}

	stored := Role{}

	err = s.storageClient.InsertRole(ctx, stored)
	if err != nil {
		return nil, errors.Wrap(err, "could not store role for user")
	}

	return &stored, nil
}
