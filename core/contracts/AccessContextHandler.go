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

// AccessContextHandlerMetaData contains all meta data concerning the AccessContextHandler contract.
var AccessContextHandlerMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"createContextInstance\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"deleteContextInstance\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"}],\"name\":\"getContextInstance\",\"outputs\":[{\"internalType\":\"contractIContextInstance\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"sessionRegistry\",\"type\":\"address\"}],\"name\":\"setSessionRegistry\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policyContexts\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policies\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes[]\",\"name\":\"_args\",\"type\":\"bytes[]\"},{\"internalType\":\"bytes32\",\"name\":\"_tokenId\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_token\",\"type\":\"bytes32\"}],\"name\":\"startSession\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// AccessContextHandlerABI is the input ABI used to generate the binding from.
// Deprecated: Use AccessContextHandlerMetaData.ABI instead.
var AccessContextHandlerABI = AccessContextHandlerMetaData.ABI

// AccessContextHandler is an auto generated Go binding around an Ethereum contract.
type AccessContextHandler struct {
	AccessContextHandlerCaller     // Read-only binding to the contract
	AccessContextHandlerTransactor // Write-only binding to the contract
	AccessContextHandlerFilterer   // Log filterer for contract events
}

// AccessContextHandlerCaller is an auto generated read-only Go binding around an Ethereum contract.
type AccessContextHandlerCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextHandlerTransactor is an auto generated write-only Go binding around an Ethereum contract.
type AccessContextHandlerTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextHandlerFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type AccessContextHandlerFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextHandlerSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type AccessContextHandlerSession struct {
	Contract     *AccessContextHandler // Generic contract binding to set the session for
	CallOpts     bind.CallOpts         // Call options to use throughout this session
	TransactOpts bind.TransactOpts     // Transaction auth options to use throughout this session
}

// AccessContextHandlerCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type AccessContextHandlerCallerSession struct {
	Contract *AccessContextHandlerCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts               // Call options to use throughout this session
}

// AccessContextHandlerTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type AccessContextHandlerTransactorSession struct {
	Contract     *AccessContextHandlerTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts               // Transaction auth options to use throughout this session
}

// AccessContextHandlerRaw is an auto generated low-level Go binding around an Ethereum contract.
type AccessContextHandlerRaw struct {
	Contract *AccessContextHandler // Generic contract binding to access the raw methods on
}

// AccessContextHandlerCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type AccessContextHandlerCallerRaw struct {
	Contract *AccessContextHandlerCaller // Generic read-only contract binding to access the raw methods on
}

// AccessContextHandlerTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type AccessContextHandlerTransactorRaw struct {
	Contract *AccessContextHandlerTransactor // Generic write-only contract binding to access the raw methods on
}

// NewAccessContextHandler creates a new instance of AccessContextHandler, bound to a specific deployed contract.
func NewAccessContextHandler(address common.Address, backend bind.ContractBackend) (*AccessContextHandler, error) {
	contract, err := bindAccessContextHandler(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &AccessContextHandler{AccessContextHandlerCaller: AccessContextHandlerCaller{contract: contract}, AccessContextHandlerTransactor: AccessContextHandlerTransactor{contract: contract}, AccessContextHandlerFilterer: AccessContextHandlerFilterer{contract: contract}}, nil
}

// NewAccessContextHandlerCaller creates a new read-only instance of AccessContextHandler, bound to a specific deployed contract.
func NewAccessContextHandlerCaller(address common.Address, caller bind.ContractCaller) (*AccessContextHandlerCaller, error) {
	contract, err := bindAccessContextHandler(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &AccessContextHandlerCaller{contract: contract}, nil
}

// NewAccessContextHandlerTransactor creates a new write-only instance of AccessContextHandler, bound to a specific deployed contract.
func NewAccessContextHandlerTransactor(address common.Address, transactor bind.ContractTransactor) (*AccessContextHandlerTransactor, error) {
	contract, err := bindAccessContextHandler(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &AccessContextHandlerTransactor{contract: contract}, nil
}

// NewAccessContextHandlerFilterer creates a new log filterer instance of AccessContextHandler, bound to a specific deployed contract.
func NewAccessContextHandlerFilterer(address common.Address, filterer bind.ContractFilterer) (*AccessContextHandlerFilterer, error) {
	contract, err := bindAccessContextHandler(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &AccessContextHandlerFilterer{contract: contract}, nil
}

// bindAccessContextHandler binds a generic wrapper to an already deployed contract.
func bindAccessContextHandler(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := AccessContextHandlerMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_AccessContextHandler *AccessContextHandlerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _AccessContextHandler.Contract.AccessContextHandlerCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_AccessContextHandler *AccessContextHandlerRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.AccessContextHandlerTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_AccessContextHandler *AccessContextHandlerRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.AccessContextHandlerTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_AccessContextHandler *AccessContextHandlerCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _AccessContextHandler.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_AccessContextHandler *AccessContextHandlerTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_AccessContextHandler *AccessContextHandlerTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.contract.Transact(opts, method, params...)
}

// GetContextInstance is a free data retrieval call binding the contract method 0xa71a77d2.
//
// Solidity: function getContextInstance(bytes32 _id) view returns(address)
func (_AccessContextHandler *AccessContextHandlerCaller) GetContextInstance(opts *bind.CallOpts, _id [32]byte) (common.Address, error) {
	var out []interface{}
	err := _AccessContextHandler.contract.Call(opts, &out, "getContextInstance", _id)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetContextInstance is a free data retrieval call binding the contract method 0xa71a77d2.
//
// Solidity: function getContextInstance(bytes32 _id) view returns(address)
func (_AccessContextHandler *AccessContextHandlerSession) GetContextInstance(_id [32]byte) (common.Address, error) {
	return _AccessContextHandler.Contract.GetContextInstance(&_AccessContextHandler.CallOpts, _id)
}

// GetContextInstance is a free data retrieval call binding the contract method 0xa71a77d2.
//
// Solidity: function getContextInstance(bytes32 _id) view returns(address)
func (_AccessContextHandler *AccessContextHandlerCallerSession) GetContextInstance(_id [32]byte) (common.Address, error) {
	return _AccessContextHandler.Contract.GetContextInstance(&_AccessContextHandler.CallOpts, _id)
}

// CreateContextInstance is a paid mutator transaction binding the contract method 0x72a4b4be.
//
// Solidity: function createContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) CreateContextInstance(opts *bind.TransactOpts, _id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "createContextInstance", _id, _did)
}

// CreateContextInstance is a paid mutator transaction binding the contract method 0x72a4b4be.
//
// Solidity: function createContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerSession) CreateContextInstance(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.CreateContextInstance(&_AccessContextHandler.TransactOpts, _id, _did)
}

// CreateContextInstance is a paid mutator transaction binding the contract method 0x72a4b4be.
//
// Solidity: function createContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) CreateContextInstance(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.CreateContextInstance(&_AccessContextHandler.TransactOpts, _id, _did)
}

// DeleteContextInstance is a paid mutator transaction binding the contract method 0xe657c9e9.
//
// Solidity: function deleteContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) DeleteContextInstance(opts *bind.TransactOpts, _id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "deleteContextInstance", _id, _did)
}

// DeleteContextInstance is a paid mutator transaction binding the contract method 0xe657c9e9.
//
// Solidity: function deleteContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerSession) DeleteContextInstance(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.DeleteContextInstance(&_AccessContextHandler.TransactOpts, _id, _did)
}

// DeleteContextInstance is a paid mutator transaction binding the contract method 0xe657c9e9.
//
// Solidity: function deleteContextInstance(bytes32 _id, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) DeleteContextInstance(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.DeleteContextInstance(&_AccessContextHandler.TransactOpts, _id, _did)
}

// SetSessionRegistry is a paid mutator transaction binding the contract method 0x4fd9d24b.
//
// Solidity: function setSessionRegistry(address sessionRegistry) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) SetSessionRegistry(opts *bind.TransactOpts, sessionRegistry common.Address) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "setSessionRegistry", sessionRegistry)
}

// SetSessionRegistry is a paid mutator transaction binding the contract method 0x4fd9d24b.
//
// Solidity: function setSessionRegistry(address sessionRegistry) returns()
func (_AccessContextHandler *AccessContextHandlerSession) SetSessionRegistry(sessionRegistry common.Address) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.SetSessionRegistry(&_AccessContextHandler.TransactOpts, sessionRegistry)
}

// SetSessionRegistry is a paid mutator transaction binding the contract method 0x4fd9d24b.
//
// Solidity: function setSessionRegistry(address sessionRegistry) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) SetSessionRegistry(sessionRegistry common.Address) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.SetSessionRegistry(&_AccessContextHandler.TransactOpts, sessionRegistry)
}

// StartSession is a paid mutator transaction binding the contract method 0x76ed4a6c.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, bytes[] _args, bytes32 _tokenId, bytes32 _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) StartSession(opts *bind.TransactOpts, _roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _args [][]byte, _tokenId [32]byte, _token [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "startSession", _roleContext, _role, _did, _policyContexts, _policies, _args, _tokenId, _token)
}

// StartSession is a paid mutator transaction binding the contract method 0x76ed4a6c.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, bytes[] _args, bytes32 _tokenId, bytes32 _token) returns()
func (_AccessContextHandler *AccessContextHandlerSession) StartSession(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _args [][]byte, _tokenId [32]byte, _token [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _args, _tokenId, _token)
}

// StartSession is a paid mutator transaction binding the contract method 0x76ed4a6c.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, bytes[] _args, bytes32 _tokenId, bytes32 _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) StartSession(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _args [][]byte, _tokenId [32]byte, _token [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _args, _tokenId, _token)
}

