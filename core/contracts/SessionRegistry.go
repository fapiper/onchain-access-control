// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package contracts

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// SessionRegistryMetaData contains all meta data concerning the SessionRegistry contract.
var SessionRegistryMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"contextHandler\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"didRegistry\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"}],\"name\":\"isSessionValid\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"}],\"name\":\"revokeSession\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"contextHandler\",\"type\":\"address\"}],\"name\":\"setContextHandler\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_token\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_subject\",\"type\":\"bytes32\"}],\"name\":\"startSession\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// SessionRegistryABI is the input ABI used to generate the binding from.
// Deprecated: Use SessionRegistryMetaData.ABI instead.
var SessionRegistryABI = SessionRegistryMetaData.ABI

// SessionRegistry is an auto generated Go binding around an Ethereum contract.
type SessionRegistry struct {
	SessionRegistryCaller     // Read-only binding to the contract
	SessionRegistryTransactor // Write-only binding to the contract
	SessionRegistryFilterer   // Log filterer for contract events
}

// SessionRegistryCaller is an auto generated read-only Go binding around an Ethereum contract.
type SessionRegistryCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SessionRegistryTransactor is an auto generated write-only Go binding around an Ethereum contract.
type SessionRegistryTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SessionRegistryFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type SessionRegistryFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SessionRegistrySession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type SessionRegistrySession struct {
	Contract     *SessionRegistry  // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// SessionRegistryCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type SessionRegistryCallerSession struct {
	Contract *SessionRegistryCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts          // Call options to use throughout this session
}

// SessionRegistryTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type SessionRegistryTransactorSession struct {
	Contract     *SessionRegistryTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts          // Transaction auth options to use throughout this session
}

// SessionRegistryRaw is an auto generated low-level Go binding around an Ethereum contract.
type SessionRegistryRaw struct {
	Contract *SessionRegistry // Generic contract binding to access the raw methods on
}

// SessionRegistryCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type SessionRegistryCallerRaw struct {
	Contract *SessionRegistryCaller // Generic read-only contract binding to access the raw methods on
}

// SessionRegistryTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type SessionRegistryTransactorRaw struct {
	Contract *SessionRegistryTransactor // Generic write-only contract binding to access the raw methods on
}

// NewSessionRegistry creates a new instance of SessionRegistry, bound to a specific deployed contract.
func NewSessionRegistry(address common.Address, backend bind.ContractBackend) (*SessionRegistry, error) {
	contract, err := bindSessionRegistry(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &SessionRegistry{SessionRegistryCaller: SessionRegistryCaller{contract: contract}, SessionRegistryTransactor: SessionRegistryTransactor{contract: contract}, SessionRegistryFilterer: SessionRegistryFilterer{contract: contract}}, nil
}

// NewSessionRegistryCaller creates a new read-only instance of SessionRegistry, bound to a specific deployed contract.
func NewSessionRegistryCaller(address common.Address, caller bind.ContractCaller) (*SessionRegistryCaller, error) {
	contract, err := bindSessionRegistry(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &SessionRegistryCaller{contract: contract}, nil
}

// NewSessionRegistryTransactor creates a new write-only instance of SessionRegistry, bound to a specific deployed contract.
func NewSessionRegistryTransactor(address common.Address, transactor bind.ContractTransactor) (*SessionRegistryTransactor, error) {
	contract, err := bindSessionRegistry(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &SessionRegistryTransactor{contract: contract}, nil
}

// NewSessionRegistryFilterer creates a new log filterer instance of SessionRegistry, bound to a specific deployed contract.
func NewSessionRegistryFilterer(address common.Address, filterer bind.ContractFilterer) (*SessionRegistryFilterer, error) {
	contract, err := bindSessionRegistry(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &SessionRegistryFilterer{contract: contract}, nil
}

// bindSessionRegistry binds a generic wrapper to an already deployed contract.
func bindSessionRegistry(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := SessionRegistryMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_SessionRegistry *SessionRegistryRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _SessionRegistry.Contract.SessionRegistryCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_SessionRegistry *SessionRegistryRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _SessionRegistry.Contract.SessionRegistryTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_SessionRegistry *SessionRegistryRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _SessionRegistry.Contract.SessionRegistryTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_SessionRegistry *SessionRegistryCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _SessionRegistry.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_SessionRegistry *SessionRegistryTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _SessionRegistry.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_SessionRegistry *SessionRegistryTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _SessionRegistry.Contract.contract.Transact(opts, method, params...)
}

// IsSessionValid is a free data retrieval call binding the contract method 0xfa333d9b.
//
// Solidity: function isSessionValid(bytes32 _id) view returns(bool)
func (_SessionRegistry *SessionRegistryCaller) IsSessionValid(opts *bind.CallOpts, _id [32]byte) (bool, error) {
	var out []interface{}
	err := _SessionRegistry.contract.Call(opts, &out, "isSessionValid", _id)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsSessionValid is a free data retrieval call binding the contract method 0xfa333d9b.
//
// Solidity: function isSessionValid(bytes32 _id) view returns(bool)
func (_SessionRegistry *SessionRegistrySession) IsSessionValid(_id [32]byte) (bool, error) {
	return _SessionRegistry.Contract.IsSessionValid(&_SessionRegistry.CallOpts, _id)
}

// IsSessionValid is a free data retrieval call binding the contract method 0xfa333d9b.
//
// Solidity: function isSessionValid(bytes32 _id) view returns(bool)
func (_SessionRegistry *SessionRegistryCallerSession) IsSessionValid(_id [32]byte) (bool, error) {
	return _SessionRegistry.Contract.IsSessionValid(&_SessionRegistry.CallOpts, _id)
}

// RevokeSession is a paid mutator transaction binding the contract method 0xa7fed385.
//
// Solidity: function revokeSession(bytes32 _id) returns()
func (_SessionRegistry *SessionRegistryTransactor) RevokeSession(opts *bind.TransactOpts, _id [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.contract.Transact(opts, "revokeSession", _id)
}

// RevokeSession is a paid mutator transaction binding the contract method 0xa7fed385.
//
// Solidity: function revokeSession(bytes32 _id) returns()
func (_SessionRegistry *SessionRegistrySession) RevokeSession(_id [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.Contract.RevokeSession(&_SessionRegistry.TransactOpts, _id)
}

// RevokeSession is a paid mutator transaction binding the contract method 0xa7fed385.
//
// Solidity: function revokeSession(bytes32 _id) returns()
func (_SessionRegistry *SessionRegistryTransactorSession) RevokeSession(_id [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.Contract.RevokeSession(&_SessionRegistry.TransactOpts, _id)
}

// SetContextHandler is a paid mutator transaction binding the contract method 0x31487652.
//
// Solidity: function setContextHandler(address contextHandler) returns()
func (_SessionRegistry *SessionRegistryTransactor) SetContextHandler(opts *bind.TransactOpts, contextHandler common.Address) (*types.Transaction, error) {
	return _SessionRegistry.contract.Transact(opts, "setContextHandler", contextHandler)
}

// SetContextHandler is a paid mutator transaction binding the contract method 0x31487652.
//
// Solidity: function setContextHandler(address contextHandler) returns()
func (_SessionRegistry *SessionRegistrySession) SetContextHandler(contextHandler common.Address) (*types.Transaction, error) {
	return _SessionRegistry.Contract.SetContextHandler(&_SessionRegistry.TransactOpts, contextHandler)
}

// SetContextHandler is a paid mutator transaction binding the contract method 0x31487652.
//
// Solidity: function setContextHandler(address contextHandler) returns()
func (_SessionRegistry *SessionRegistryTransactorSession) SetContextHandler(contextHandler common.Address) (*types.Transaction, error) {
	return _SessionRegistry.Contract.SetContextHandler(&_SessionRegistry.TransactOpts, contextHandler)
}

// StartSession is a paid mutator transaction binding the contract method 0x648fce79.
//
// Solidity: function startSession(bytes32 _id, bytes32 _token, bytes32 _subject) returns()
func (_SessionRegistry *SessionRegistryTransactor) StartSession(opts *bind.TransactOpts, _id [32]byte, _token [32]byte, _subject [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.contract.Transact(opts, "startSession", _id, _token, _subject)
}

// StartSession is a paid mutator transaction binding the contract method 0x648fce79.
//
// Solidity: function startSession(bytes32 _id, bytes32 _token, bytes32 _subject) returns()
func (_SessionRegistry *SessionRegistrySession) StartSession(_id [32]byte, _token [32]byte, _subject [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.Contract.StartSession(&_SessionRegistry.TransactOpts, _id, _token, _subject)
}

// StartSession is a paid mutator transaction binding the contract method 0x648fce79.
//
// Solidity: function startSession(bytes32 _id, bytes32 _token, bytes32 _subject) returns()
func (_SessionRegistry *SessionRegistryTransactorSession) StartSession(_id [32]byte, _token [32]byte, _subject [32]byte) (*types.Transaction, error) {
	return _SessionRegistry.Contract.StartSession(&_SessionRegistry.TransactOpts, _id, _token, _subject)
}

