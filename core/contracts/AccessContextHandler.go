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

// IPolicyVerifierProof is an auto generated low-level Go binding around an user-defined struct.
type IPolicyVerifierProof struct {
	A PairingG1Point
	B PairingG2Point
	C PairingG1Point
}

// PairingG1Point is an auto generated low-level Go binding around an user-defined struct.
type PairingG1Point struct {
	X *big.Int
	Y *big.Int
}

// PairingG2Point is an auto generated low-level Go binding around an user-defined struct.
type PairingG2Point struct {
	X [2]*big.Int
	Y [2]*big.Int
}

// AccessContextHandlerMetaData contains all meta data concerning the AccessContextHandler contract.
var AccessContextHandlerMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"didRegistry\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"ERC1167FailedCreateClone\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"accessContext\",\"type\":\"address\"}],\"name\":\"CreateContextInstance\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes20\",\"name\":\"_salt\",\"type\":\"bytes20\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"createContextInstance\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"deleteContextInstance\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"}],\"name\":\"getContextInstance\",\"outputs\":[{\"internalType\":\"contractIContextInstance\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policyContexts\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policies\",\"type\":\"bytes32[]\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"a\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256[2]\",\"name\":\"X\",\"type\":\"uint256[2]\"},{\"internalType\":\"uint256[2]\",\"name\":\"Y\",\"type\":\"uint256[2]\"}],\"internalType\":\"structPairing.G2Point\",\"name\":\"b\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"c\",\"type\":\"tuple\"}],\"internalType\":\"structIPolicyVerifier.Proof[]\",\"name\":\"_proofs\",\"type\":\"tuple[]\"},{\"internalType\":\"uint256[20][]\",\"name\":\"_inputs\",\"type\":\"uint256[20][]\"}],\"name\":\"grantRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"isSession\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"}],\"name\":\"isSession\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"sessionRegistry\",\"type\":\"address\"}],\"name\":\"setSessionRegistry\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_tokenId\",\"type\":\"bytes32\"},{\"internalType\":\"bytes\",\"name\":\"_token\",\"type\":\"bytes\"}],\"name\":\"startSession\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policyContexts\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policies\",\"type\":\"bytes32[]\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"a\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256[2]\",\"name\":\"X\",\"type\":\"uint256[2]\"},{\"internalType\":\"uint256[2]\",\"name\":\"Y\",\"type\":\"uint256[2]\"}],\"internalType\":\"structPairing.G2Point\",\"name\":\"b\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"c\",\"type\":\"tuple\"}],\"internalType\":\"structIPolicyVerifier.Proof[]\",\"name\":\"_proofs\",\"type\":\"tuple[]\"},{\"internalType\":\"uint256[20][]\",\"name\":\"_inputs\",\"type\":\"uint256[20][]\"},{\"internalType\":\"bytes32\",\"name\":\"_tokenId\",\"type\":\"bytes32\"},{\"internalType\":\"bytes\",\"name\":\"_token\",\"type\":\"bytes\"}],\"name\":\"startSession\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
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

// CreateContextInstance is a paid mutator transaction binding the contract method 0x656c4309.
//
// Solidity: function createContextInstance(bytes32 _id, bytes20 _salt, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) CreateContextInstance(opts *bind.TransactOpts, _id [32]byte, _salt [20]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "createContextInstance", _id, _salt, _did)
}

// CreateContextInstance is a paid mutator transaction binding the contract method 0x656c4309.
//
// Solidity: function createContextInstance(bytes32 _id, bytes20 _salt, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerSession) CreateContextInstance(_id [32]byte, _salt [20]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.CreateContextInstance(&_AccessContextHandler.TransactOpts, _id, _salt, _did)
}

// CreateContextInstance is a paid mutator transaction binding the contract method 0x656c4309.
//
// Solidity: function createContextInstance(bytes32 _id, bytes20 _salt, bytes32 _did) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) CreateContextInstance(_id [32]byte, _salt [20]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.CreateContextInstance(&_AccessContextHandler.TransactOpts, _id, _salt, _did)
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

// GrantRole is a paid mutator transaction binding the contract method 0x86490b3e.
//
// Solidity: function grantRole(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) GrantRole(opts *bind.TransactOpts, _roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "grantRole", _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// GrantRole is a paid mutator transaction binding the contract method 0x86490b3e.
//
// Solidity: function grantRole(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContextHandler *AccessContextHandlerSession) GrantRole(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.GrantRole(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// GrantRole is a paid mutator transaction binding the contract method 0x86490b3e.
//
// Solidity: function grantRole(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) GrantRole(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.GrantRole(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// IsSession is a paid mutator transaction binding the contract method 0x011255b5.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did) returns(bool)
func (_AccessContextHandler *AccessContextHandlerTransactor) IsSession(opts *bind.TransactOpts, _id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "isSession", _id, _did)
}

// IsSession is a paid mutator transaction binding the contract method 0x011255b5.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did) returns(bool)
func (_AccessContextHandler *AccessContextHandlerSession) IsSession(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.IsSession(&_AccessContextHandler.TransactOpts, _id, _did)
}

// IsSession is a paid mutator transaction binding the contract method 0x011255b5.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did) returns(bool)
func (_AccessContextHandler *AccessContextHandlerTransactorSession) IsSession(_id [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.IsSession(&_AccessContextHandler.TransactOpts, _id, _did)
}

// IsSession0 is a paid mutator transaction binding the contract method 0xc25e93da.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did, bytes32 _roleContext, bytes32 _role) returns(bool)
func (_AccessContextHandler *AccessContextHandlerTransactor) IsSession0(opts *bind.TransactOpts, _id [32]byte, _did [32]byte, _roleContext [32]byte, _role [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "isSession0", _id, _did, _roleContext, _role)
}

// IsSession0 is a paid mutator transaction binding the contract method 0xc25e93da.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did, bytes32 _roleContext, bytes32 _role) returns(bool)
func (_AccessContextHandler *AccessContextHandlerSession) IsSession0(_id [32]byte, _did [32]byte, _roleContext [32]byte, _role [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.IsSession0(&_AccessContextHandler.TransactOpts, _id, _did, _roleContext, _role)
}

// IsSession0 is a paid mutator transaction binding the contract method 0xc25e93da.
//
// Solidity: function isSession(bytes32 _id, bytes32 _did, bytes32 _roleContext, bytes32 _role) returns(bool)
func (_AccessContextHandler *AccessContextHandlerTransactorSession) IsSession0(_id [32]byte, _did [32]byte, _roleContext [32]byte, _role [32]byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.IsSession0(&_AccessContextHandler.TransactOpts, _id, _did, _roleContext, _role)
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

// StartSession is a paid mutator transaction binding the contract method 0x9e41f61e.
//
// Solidity: function startSession(bytes32 _did, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) StartSession(opts *bind.TransactOpts, _did [32]byte, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "startSession", _did, _tokenId, _token)
}

// StartSession is a paid mutator transaction binding the contract method 0x9e41f61e.
//
// Solidity: function startSession(bytes32 _did, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerSession) StartSession(_did [32]byte, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession(&_AccessContextHandler.TransactOpts, _did, _tokenId, _token)
}

// StartSession is a paid mutator transaction binding the contract method 0x9e41f61e.
//
// Solidity: function startSession(bytes32 _did, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) StartSession(_did [32]byte, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession(&_AccessContextHandler.TransactOpts, _did, _tokenId, _token)
}

// StartSession0 is a paid mutator transaction binding the contract method 0xc83992ef.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactor) StartSession0(opts *bind.TransactOpts, _roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.contract.Transact(opts, "startSession0", _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs, _tokenId, _token)
}

// StartSession0 is a paid mutator transaction binding the contract method 0xc83992ef.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerSession) StartSession0(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession0(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs, _tokenId, _token)
}

// StartSession0 is a paid mutator transaction binding the contract method 0xc83992ef.
//
// Solidity: function startSession(bytes32 _roleContext, bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs, bytes32 _tokenId, bytes _token) returns()
func (_AccessContextHandler *AccessContextHandlerTransactorSession) StartSession0(_roleContext [32]byte, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int, _tokenId [32]byte, _token []byte) (*types.Transaction, error) {
	return _AccessContextHandler.Contract.StartSession0(&_AccessContextHandler.TransactOpts, _roleContext, _role, _did, _policyContexts, _policies, _proofs, _inputs, _tokenId, _token)
}

// AccessContextHandlerCreateContextInstanceIterator is returned from FilterCreateContextInstance and is used to iterate over the raw logs and unpacked data for CreateContextInstance events raised by the AccessContextHandler contract.
type AccessContextHandlerCreateContextInstanceIterator struct {
	Event *AccessContextHandlerCreateContextInstance // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *AccessContextHandlerCreateContextInstanceIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(AccessContextHandlerCreateContextInstance)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(AccessContextHandlerCreateContextInstance)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *AccessContextHandlerCreateContextInstanceIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *AccessContextHandlerCreateContextInstanceIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// AccessContextHandlerCreateContextInstance represents a CreateContextInstance event raised by the AccessContextHandler contract.
type AccessContextHandlerCreateContextInstance struct {
	AccessContext common.Address
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterCreateContextInstance is a free log retrieval operation binding the contract event 0xe949066119e817dca657ddef4b6bb5d7f3d1ccec2153ae908edcec5205f89000.
//
// Solidity: event CreateContextInstance(address indexed accessContext)
func (_AccessContextHandler *AccessContextHandlerFilterer) FilterCreateContextInstance(opts *bind.FilterOpts, accessContext []common.Address) (*AccessContextHandlerCreateContextInstanceIterator, error) {

	var accessContextRule []interface{}
	for _, accessContextItem := range accessContext {
		accessContextRule = append(accessContextRule, accessContextItem)
	}

	logs, sub, err := _AccessContextHandler.contract.FilterLogs(opts, "CreateContextInstance", accessContextRule)
	if err != nil {
		return nil, err
	}
	return &AccessContextHandlerCreateContextInstanceIterator{contract: _AccessContextHandler.contract, event: "CreateContextInstance", logs: logs, sub: sub}, nil
}

// WatchCreateContextInstance is a free log subscription operation binding the contract event 0xe949066119e817dca657ddef4b6bb5d7f3d1ccec2153ae908edcec5205f89000.
//
// Solidity: event CreateContextInstance(address indexed accessContext)
func (_AccessContextHandler *AccessContextHandlerFilterer) WatchCreateContextInstance(opts *bind.WatchOpts, sink chan<- *AccessContextHandlerCreateContextInstance, accessContext []common.Address) (event.Subscription, error) {

	var accessContextRule []interface{}
	for _, accessContextItem := range accessContext {
		accessContextRule = append(accessContextRule, accessContextItem)
	}

	logs, sub, err := _AccessContextHandler.contract.WatchLogs(opts, "CreateContextInstance", accessContextRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(AccessContextHandlerCreateContextInstance)
				if err := _AccessContextHandler.contract.UnpackLog(event, "CreateContextInstance", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseCreateContextInstance is a log parse operation binding the contract event 0xe949066119e817dca657ddef4b6bb5d7f3d1ccec2153ae908edcec5205f89000.
//
// Solidity: event CreateContextInstance(address indexed accessContext)
func (_AccessContextHandler *AccessContextHandlerFilterer) ParseCreateContextInstance(log types.Log) (*AccessContextHandlerCreateContextInstance, error) {
	event := new(AccessContextHandlerCreateContextInstance)
	if err := _AccessContextHandler.contract.UnpackLog(event, "CreateContextInstance", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

