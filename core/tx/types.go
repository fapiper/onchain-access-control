package tx

import (
	"bytes"
	"context"
	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/pkg/errors"
	"log"
	"math/big"
	"strings"
)

var (
	// ErrInvalidSendTxArgs is returned when the structure of SendTxArgs is ambigious.
	ErrInvalidSendTxArgs = errors.New("transaction arguments are invalid")
	// ErrUnexpectedArgs is returned when args are of unexpected length.
	ErrUnexpectedArgs = errors.New("unexpected args")
	//ErrInvalidTxSender is returned when selected account is different than From field.
	ErrInvalidTxSender = errors.New("transaction can only be send by its creator")
	//ErrAccountDoesntExist is sent when provided sub-account is not stored in database.
	ErrAccountDoesntExist = errors.New("account doesn't exist")
)

// PendingNonceProvider provides information about nonces.
type PendingNonceProvider interface {
	PendingNonceAt(ctx context.Context, account common.Address) (uint64, error)
}

// GasCalculator provides methods for estimating and pricing gas.
type GasCalculator interface {
	ethereum.GasEstimator
	ethereum.GasPricer
}

// SendTxArgs represents the arguments to submit a new transaction into the transaction pool.
// This struct is based on go-ethereum's type in internal/ethapi/api.go, but we have freedom
// over the exact layout of this struct.
type SendTxArgs struct {
	From                 common.Address  `json:"from"`
	To                   *common.Address `json:"to"`
	Gas                  *hexutil.Uint64 `json:"gas"`
	GasPrice             *hexutil.Big    `json:"gasPrice"`
	Value                *hexutil.Big    `json:"value"`
	Nonce                *hexutil.Uint64 `json:"nonce"`
	MaxFeePerGas         *hexutil.Big    `json:"maxFeePerGas"`
	MaxPriorityFeePerGas *hexutil.Big    `json:"maxPriorityFeePerGas"`
	// We keep both "input" and "data" for backward compatibility.
	// "input" is a preferred field.
	Input hexutil.Bytes `json:"input"`
	Data  hexutil.Bytes `json:"data"`
}

// Valid checks whether this structure is filled in correctly.
func (args SendTxArgs) Valid() bool {
	// if at least one of the fields is empty, it is a valid struct
	if isNilOrEmpty(args.Input) || isNilOrEmpty(args.Data) {
		return true
	}

	// we only allow both fields to present if they have the same data
	return bytes.Equal(args.Input, args.Data)
}

// IsDynamicFeeTx checks whether dynamic fee parameters are set for the tx
func (args SendTxArgs) IsDynamicFeeTx() bool {
	return args.MaxFeePerGas != nil && args.MaxPriorityFeePerGas != nil
}

// GetInput returns either Input or Data field's value dependent on what is filled.
func (args SendTxArgs) GetInput() hexutil.Bytes {
	if !isNilOrEmpty(args.Input) {
		return args.Input
	}

	return args.Data
}

func (args SendTxArgs) ToTransactOpts(key, password string, chainID uint64) *bind.TransactOpts {
	var gasFeeCap *big.Int
	if args.MaxFeePerGas != nil {
		gasFeeCap = (*big.Int)(args.MaxFeePerGas)
	}

	var gasTipCap *big.Int
	if args.MaxPriorityFeePerGas != nil {
		gasTipCap = (*big.Int)(args.MaxPriorityFeePerGas)
	}

	var nonce *big.Int
	if args.Nonce != nil {
		nonce = new(big.Int).SetUint64((uint64)(*args.Nonce))
	}

	var gasPrice *big.Int
	if args.GasPrice != nil {
		gasPrice = (*big.Int)(args.GasPrice)
	}

	var gasLimit uint64
	if args.Gas != nil {
		gasLimit = uint64(*args.Gas)
	}

	auth, err := bind.NewTransactorWithChainID(strings.NewReader(key), password, new(big.Int).SetUint64(chainID))
	if err != nil {
		log.Fatalf("Failed to create authorized transactor: %v", err)
	}

	return &bind.TransactOpts{
		From:      auth.From,
		Signer:    auth.Signer,
		GasPrice:  gasPrice,
		GasLimit:  gasLimit,
		GasFeeCap: gasFeeCap,
		GasTipCap: gasTipCap,
		Nonce:     nonce,
	}
}

func isNilOrEmpty(bytes hexutil.Bytes) bool {
	return len(bytes) == 0
}
