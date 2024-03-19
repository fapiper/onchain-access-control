package rpc

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/pkg/errors"
	"log"
	"math/big"
)

type Wallet struct {
	ChainID    *big.Int
	PrivateKey *ecdsa.PrivateKey
	PublicKey  *ecdsa.PublicKey
	Address    common.Address
	Client     *ethclient.Client
}

func NewWallet(privateKey string, chainID uint64) (*Wallet, error) {
	ethClient := NewEthClient()

	privateKeyECDSA, err := crypto.HexToECDSA(privateKey)
	if err != nil {
		return nil, errors.Wrap(err, "could not generate private key")
	}

	publicKey := privateKeyECDSA.Public()

	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return nil, errors.Wrap(err, "unable to derive public key")
	}

	wallet := Wallet{
		Client:     ethClient,
		ChainID:    new(big.Int).SetUint64(chainID),
		PrivateKey: privateKeyECDSA,
		PublicKey:  publicKeyECDSA,
		Address:    crypto.PubkeyToAddress(*publicKeyECDSA),
	}
	return &wallet, nil
}

func (w Wallet) ToCallOpts() *bind.CallOpts {
	return &bind.CallOpts{
		From: w.Address,
	}
}

func (w Wallet) ToTransactOpts() (*bind.TransactOpts, error) {

	nonce, err := w.Client.PendingNonceAt(context.Background(), w.Address)
	if err != nil {
		return nil, errors.Wrap(err, "unable to derive nonce")
	}

	gasPrice, err := w.Client.SuggestGasPrice(context.Background())
	if err != nil {
		return nil, errors.Wrap(err, "could not get gas price, quitting")
	}

	auth, err := bind.NewKeyedTransactorWithChainID(w.PrivateKey, w.ChainID)
	if err != nil {
		log.Fatalf("Failed to create authorized transactor: %v", err)
	}

	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)        // in wei
	auth.GasLimit = uint64(8_000_000) // in units
	auth.GasPrice = gasPrice

	return auth, nil
}

func (w Wallet) GetDID() string {
	return fmt.Sprintf("did:pkh:eip155:%d:%s", w.ChainID, w.Address)
}
func (w Wallet) GetDIDHash() common.Hash {
	did := w.GetDID()
	return crypto.Keccak256Hash([]byte(did))
}
