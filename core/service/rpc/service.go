package rpc

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/env"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/goccy/go-json"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"math/big"
)

type Service struct {
	Wallet *Wallet
}

func (s Service) Type() framework.Type {
	return framework.Schema
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.Wallet == nil {
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
		Wallet: wallet,
	}

	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}
	return &service, nil
}

type GrantRoleParams struct {
	RoleIdentifier   persist.RoleIdentifier
	DID              common.Hash
	PolicyIdentifier persist.PolicyIdentifier
	Proof            contracts.IPolicyVerifierProof
	Inputs           [20]*big.Int
}

// GrantRole grants a role to a user
func (s Service) GrantRole(ctx context.Context, params GrantRoleParams) (*types.Receipt, error) {
	address := persist.Address("0x424B7637A40E105889B592155Ab721c347a845D3")
	instance, err := contracts.NewAccessContextHandler(address.Address(), s.Wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.Wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	tx, err := instance.GrantRole(
		txOpts,
		params.RoleIdentifier.ContextID,
		params.RoleIdentifier.RoleID,
		params.DID,
		[][32]byte{params.PolicyIdentifier.ContextID},
		[][32]byte{params.PolicyIdentifier.PolicyID},
		[]contracts.IPolicyVerifierProof{params.Proof},
		[][20]*big.Int{params.Inputs},
	)
	if err != nil {
		return nil, err
	}

	txJson, _ := json.MarshalIndent(tx, "", "\t")
	logrus.Infof("Sent transaction\n%s\nWaiting for confirmation...", string(txJson))

	receipt, err := bind.WaitMined(context.Background(), s.Wallet.Client, tx)
	receiptJson, _ := json.MarshalIndent(*receipt, "", "	")
	logrus.Infof("Mined transaction\n%s", string(receiptJson))
	if err != nil {
		return nil, err
	}

	return receipt, nil
}
