package rpc

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/pkg/errors"
)

type Service struct {
	wallet *Wallet
}

func (s Service) Type() framework.Type {
	return framework.Schema
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.wallet == nil {
		ae.AppendString("no wallet configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("rpc service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewRPCService() (*Service, error) {
	wallet, err := NewWallet(env.GetString("PRIVATE_KEY"), uint64(env.GetInt("CHAIN_ID")))
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "could not instantiate wallet for the rpc service")
	}

	service := Service{
		wallet: wallet,
	}

	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}
	return &service, nil
}

type GrantRoleParams struct {
	RoleId        [32]byte
	DID           [32]byte
	PolicyContext [32]byte
	PolicyId      [32]byte
	Args          []byte
}

// GrantRole grants a role to a user
func (s Service) GrantRole(ctx context.Context, address persist.Address, params GrantRoleParams) (*types.Transaction, error) {
	instance, err := contracts.NewAccessContext(address.Address(), s.wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	tx, err := instance.GrantRole(txOpts, params.RoleId, params.DID, [][32]byte{params.PolicyId}, [][32]byte{params.PolicyContext}, [][]byte{params.Args})
	if err != nil {
		return nil, err
	}

	return tx, nil
}
