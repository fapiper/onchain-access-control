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
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"math/big"
)

type Service struct {
	Wallet          *Wallet
	ContextHandler  persist.Address
	SessionRegistry persist.Address
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
		Wallet:          wallet,
		ContextHandler:  persist.Address(env.GetString("CONTEXT_HANDLER_CONTRACT")),
		SessionRegistry: persist.Address(env.GetString("SESSION_REGISTRY_CONTRACT")),
	}

	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}
	return &service, nil
}

type CreateAccessContextParams struct {
	ID   common.Hash
	Salt [20]byte
	DID  common.Hash
}

// CreateAccessContext creates a new access context
func (s Service) CreateAccessContext(ctx context.Context, params CreateAccessContextParams) (*types.Receipt, error) {
	instance, err := contracts.NewAccessContextHandler(s.ContextHandler.Address(), s.Wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.Wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	return s.waitMined(instance.CreateContextInstance(
		txOpts,
		params.ID,
		params.Salt,
		params.DID,
	))
}

// GetAccessContextAddress creates a new access context
func (s Service) GetAccessContextAddress(id common.Hash) (persist.Address, error) {
	instance, err := contracts.NewAccessContextHandlerCaller(s.ContextHandler.Address(), s.Wallet.Client)
	if err != nil {
		return "", err
	}

	txOpts := s.Wallet.ToCallOpts()
	address, err := instance.GetContextInstance(txOpts, id)
	if err != nil {
		return "", err
	}

	return persist.Address(address.String()), nil
}

type RegisterResourceParams struct {
	AccessContext persist.Address
	Role          common.Hash
	Policy        common.Hash
	Permission    common.Hash
	Resource      common.Hash
	Operations    []uint8
	Verifier      common.Address
	DID           common.Hash
}

// RegisterResource creates a new access context
func (s Service) RegisterResource(ctx context.Context, params RegisterResourceParams) (*types.Receipt, error) {
	instance, err := contracts.NewAccessContext(params.AccessContext.Address(), s.Wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.Wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	v := persist.Address("0x04756f72242049Eb05A0BAADa41E0F46828122cD")
	return s.waitMined(instance.SetupRole(txOpts, params.Role, params.Policy, params.Permission, params.Resource, params.Operations, v.Address(), params.DID))
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
	instance, err := contracts.NewAccessContextHandler(s.ContextHandler.Address(), s.Wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.Wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	return s.waitMined(instance.GrantRole(
		txOpts,
		params.RoleIdentifier.ContextID,
		params.RoleIdentifier.RoleID,
		params.DID,
		[][32]byte{params.PolicyIdentifier.ContextID},
		[][32]byte{params.PolicyIdentifier.PolicyID},
		[]contracts.IPolicyVerifierProof{params.Proof},
		[][20]*big.Int{params.Inputs},
	))
}

type StartSessionParams struct {
	DID        common.Hash
	TokenID    common.Hash
	SessionJWE []byte
}

// StartSession starts a session
func (s Service) StartSession(ctx context.Context, params StartSessionParams) (*types.Receipt, error) {
	instance, err := contracts.NewAccessContextHandler(s.ContextHandler.Address(), s.Wallet.Client)
	if err != nil {
		return nil, err
	}

	txOpts, err := s.Wallet.ToTransactOpts()
	if err != nil {
		return nil, err
	}

	return s.waitMined(instance.StartSession(
		txOpts,
		params.DID,
		params.TokenID,
		params.SessionJWE,
	))
}

type CheckSessionParams struct {
	TokenID common.Hash
	DID     common.Hash
}

// CheckSession starts a session
func (s Service) CheckSession(ctx context.Context, params CheckSessionParams) (bool, error) {
	instance, err := contracts.NewSessionRegistryCaller(s.ContextHandler.Address(), s.Wallet.Client)
	if err != nil {
		return false, err
	}

	txOpts := s.Wallet.ToCallOpts()

	return instance.IsSession(
		txOpts,
		params.TokenID,
		params.DID,
	)
}

func (s Service) waitMined(tx *types.Transaction, err error) (*types.Receipt, error) {
	if err != nil {
		return nil, err
	}

	logrus.Infof("Sent transaction %s. Waiting for confirmation...", tx.Hash())

	receipt, err := bind.WaitMined(context.Background(), s.Wallet.Client, tx)
	if receipt.Status == types.ReceiptStatusFailed {
		return nil, fmt.Errorf("Transaction status failed\n%s", receipt.TxHash)
	}
	if err != nil {
		return nil, err
	}

	return receipt, nil

}
