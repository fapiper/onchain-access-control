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

// IPolicyExtensionPolicy is an auto generated low-level Go binding around an user-defined struct.
type IPolicyExtensionPolicy struct {
	Context  [32]byte
	Id       [32]byte
	Verifier common.Address
	Exists   bool
}

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

// AccessContextMetaData contains all meta data concerning the AccessContext contract.
var AccessContextMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"owner\",\"type\":\"bytes32\"}],\"name\":\"OwnableInvalidOwner\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"did\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"OwnableUnauthorizedAccount\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"previousOwner\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"newOwner\",\"type\":\"bytes32\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"assignPermission\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_policyContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_policy\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"assignPolicy\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"_account\",\"type\":\"address\"}],\"name\":\"checkAdmin\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32[]\",\"name\":\"_contexts\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes32[]\",\"name\":\"_ids\",\"type\":\"bytes32[]\"}],\"name\":\"getPolicies\",\"outputs\":[{\"components\":[{\"internalType\":\"bytes32\",\"name\":\"context\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"id\",\"type\":\"bytes32\"},{\"internalType\":\"contractIPolicyVerifier\",\"name\":\"verifier\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"exists\",\"type\":\"bool\"}],\"internalType\":\"structIPolicyExtension.Policy[]\",\"name\":\"policies\",\"type\":\"tuple[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_context\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_id\",\"type\":\"bytes32\"}],\"name\":\"getPolicy\",\"outputs\":[{\"components\":[{\"internalType\":\"bytes32\",\"name\":\"context\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"id\",\"type\":\"bytes32\"},{\"internalType\":\"contractIPolicyVerifier\",\"name\":\"verifier\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"exists\",\"type\":\"bool\"}],\"internalType\":\"structIPolicyExtension.Policy\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policyContexts\",\"type\":\"bytes32[]\"},{\"internalType\":\"bytes32[]\",\"name\":\"_policies\",\"type\":\"bytes32[]\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"a\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256[2]\",\"name\":\"X\",\"type\":\"uint256[2]\"},{\"internalType\":\"uint256[2]\",\"name\":\"Y\",\"type\":\"uint256[2]\"}],\"internalType\":\"structPairing.G2Point\",\"name\":\"b\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"X\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"Y\",\"type\":\"uint256\"}],\"internalType\":\"structPairing.G1Point\",\"name\":\"c\",\"type\":\"tuple\"}],\"internalType\":\"structIPolicyVerifier.Proof[]\",\"name\":\"_proofs\",\"type\":\"tuple[]\"},{\"internalType\":\"uint256[20][]\",\"name\":\"_inputs\",\"type\":\"uint256[20][]\"}],\"name\":\"grantRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"hasRole\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"initialOwner\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"id\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"handler\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"didRegistry\",\"type\":\"address\"}],\"name\":\"init\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_resource\",\"type\":\"bytes32\"},{\"internalType\":\"enumPermissionExtension.Operation[]\",\"name\":\"_operations\",\"type\":\"uint8[]\"}],\"name\":\"registerPermission\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_resource\",\"type\":\"bytes32\"},{\"internalType\":\"enumPermissionExtension.Operation[]\",\"name\":\"_operations\",\"type\":\"uint8[]\"},{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"registerPermission\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_policy\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"_verifier\",\"type\":\"address\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"registerPolicy\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_policy\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"_verifier\",\"type\":\"address\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"registerPolicy\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"owner_\",\"type\":\"bytes32\"}],\"name\":\"renounceOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"revokeRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_policy\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_resource\",\"type\":\"bytes32\"},{\"internalType\":\"enumPermissionExtension.Operation[]\",\"name\":\"_operations\",\"type\":\"uint8[]\"},{\"internalType\":\"address\",\"name\":\"_verifier\",\"type\":\"address\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"setupRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_policyContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_policy\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_resource\",\"type\":\"bytes32\"},{\"internalType\":\"enumPermissionExtension.Operation[]\",\"name\":\"_operations\",\"type\":\"uint8[]\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"setupRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"oldOwner\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"newOwner\",\"type\":\"bytes32\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"_permission\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_roleContext\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_role\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"_did\",\"type\":\"bytes32\"}],\"name\":\"unassignPermission\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// AccessContextABI is the input ABI used to generate the binding from.
// Deprecated: Use AccessContextMetaData.ABI instead.
var AccessContextABI = AccessContextMetaData.ABI

// AccessContext is an auto generated Go binding around an Ethereum contract.
type AccessContext struct {
	AccessContextCaller     // Read-only binding to the contract
	AccessContextTransactor // Write-only binding to the contract
	AccessContextFilterer   // Log filterer for contract events
}

// AccessContextCaller is an auto generated read-only Go binding around an Ethereum contract.
type AccessContextCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextTransactor is an auto generated write-only Go binding around an Ethereum contract.
type AccessContextTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type AccessContextFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// AccessContextSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type AccessContextSession struct {
	Contract     *AccessContext    // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// AccessContextCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type AccessContextCallerSession struct {
	Contract *AccessContextCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts        // Call options to use throughout this session
}

// AccessContextTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type AccessContextTransactorSession struct {
	Contract     *AccessContextTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts        // Transaction auth options to use throughout this session
}

// AccessContextRaw is an auto generated low-level Go binding around an Ethereum contract.
type AccessContextRaw struct {
	Contract *AccessContext // Generic contract binding to access the raw methods on
}

// AccessContextCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type AccessContextCallerRaw struct {
	Contract *AccessContextCaller // Generic read-only contract binding to access the raw methods on
}

// AccessContextTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type AccessContextTransactorRaw struct {
	Contract *AccessContextTransactor // Generic write-only contract binding to access the raw methods on
}

// NewAccessContext creates a new instance of AccessContext, bound to a specific deployed contract.
func NewAccessContext(address common.Address, backend bind.ContractBackend) (*AccessContext, error) {
	contract, err := bindAccessContext(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &AccessContext{AccessContextCaller: AccessContextCaller{contract: contract}, AccessContextTransactor: AccessContextTransactor{contract: contract}, AccessContextFilterer: AccessContextFilterer{contract: contract}}, nil
}

// NewAccessContextCaller creates a new read-only instance of AccessContext, bound to a specific deployed contract.
func NewAccessContextCaller(address common.Address, caller bind.ContractCaller) (*AccessContextCaller, error) {
	contract, err := bindAccessContext(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &AccessContextCaller{contract: contract}, nil
}

// NewAccessContextTransactor creates a new write-only instance of AccessContext, bound to a specific deployed contract.
func NewAccessContextTransactor(address common.Address, transactor bind.ContractTransactor) (*AccessContextTransactor, error) {
	contract, err := bindAccessContext(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &AccessContextTransactor{contract: contract}, nil
}

// NewAccessContextFilterer creates a new log filterer instance of AccessContext, bound to a specific deployed contract.
func NewAccessContextFilterer(address common.Address, filterer bind.ContractFilterer) (*AccessContextFilterer, error) {
	contract, err := bindAccessContext(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &AccessContextFilterer{contract: contract}, nil
}

// bindAccessContext binds a generic wrapper to an already deployed contract.
func bindAccessContext(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := AccessContextMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_AccessContext *AccessContextRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _AccessContext.Contract.AccessContextCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_AccessContext *AccessContextRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _AccessContext.Contract.AccessContextTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_AccessContext *AccessContextRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _AccessContext.Contract.AccessContextTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_AccessContext *AccessContextCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _AccessContext.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_AccessContext *AccessContextTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _AccessContext.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_AccessContext *AccessContextTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _AccessContext.Contract.contract.Transact(opts, method, params...)
}

// GetPolicies is a free data retrieval call binding the contract method 0x32adfd2b.
//
// Solidity: function getPolicies(bytes32[] _contexts, bytes32[] _ids) view returns((bytes32,bytes32,address,bool)[] policies)
func (_AccessContext *AccessContextCaller) GetPolicies(opts *bind.CallOpts, _contexts [][32]byte, _ids [][32]byte) ([]IPolicyExtensionPolicy, error) {
	var out []interface{}
	err := _AccessContext.contract.Call(opts, &out, "getPolicies", _contexts, _ids)

	if err != nil {
		return *new([]IPolicyExtensionPolicy), err
	}

	out0 := *abi.ConvertType(out[0], new([]IPolicyExtensionPolicy)).(*[]IPolicyExtensionPolicy)

	return out0, err

}

// GetPolicies is a free data retrieval call binding the contract method 0x32adfd2b.
//
// Solidity: function getPolicies(bytes32[] _contexts, bytes32[] _ids) view returns((bytes32,bytes32,address,bool)[] policies)
func (_AccessContext *AccessContextSession) GetPolicies(_contexts [][32]byte, _ids [][32]byte) ([]IPolicyExtensionPolicy, error) {
	return _AccessContext.Contract.GetPolicies(&_AccessContext.CallOpts, _contexts, _ids)
}

// GetPolicies is a free data retrieval call binding the contract method 0x32adfd2b.
//
// Solidity: function getPolicies(bytes32[] _contexts, bytes32[] _ids) view returns((bytes32,bytes32,address,bool)[] policies)
func (_AccessContext *AccessContextCallerSession) GetPolicies(_contexts [][32]byte, _ids [][32]byte) ([]IPolicyExtensionPolicy, error) {
	return _AccessContext.Contract.GetPolicies(&_AccessContext.CallOpts, _contexts, _ids)
}

// GetPolicy is a free data retrieval call binding the contract method 0x2654083f.
//
// Solidity: function getPolicy(bytes32 _context, bytes32 _id) view returns((bytes32,bytes32,address,bool))
func (_AccessContext *AccessContextCaller) GetPolicy(opts *bind.CallOpts, _context [32]byte, _id [32]byte) (IPolicyExtensionPolicy, error) {
	var out []interface{}
	err := _AccessContext.contract.Call(opts, &out, "getPolicy", _context, _id)

	if err != nil {
		return *new(IPolicyExtensionPolicy), err
	}

	out0 := *abi.ConvertType(out[0], new(IPolicyExtensionPolicy)).(*IPolicyExtensionPolicy)

	return out0, err

}

// GetPolicy is a free data retrieval call binding the contract method 0x2654083f.
//
// Solidity: function getPolicy(bytes32 _context, bytes32 _id) view returns((bytes32,bytes32,address,bool))
func (_AccessContext *AccessContextSession) GetPolicy(_context [32]byte, _id [32]byte) (IPolicyExtensionPolicy, error) {
	return _AccessContext.Contract.GetPolicy(&_AccessContext.CallOpts, _context, _id)
}

// GetPolicy is a free data retrieval call binding the contract method 0x2654083f.
//
// Solidity: function getPolicy(bytes32 _context, bytes32 _id) view returns((bytes32,bytes32,address,bool))
func (_AccessContext *AccessContextCallerSession) GetPolicy(_context [32]byte, _id [32]byte) (IPolicyExtensionPolicy, error) {
	return _AccessContext.Contract.GetPolicy(&_AccessContext.CallOpts, _context, _id)
}

// HasRole is a free data retrieval call binding the contract method 0x0ca075d9.
//
// Solidity: function hasRole(bytes32 _role, bytes32 _did) view returns(bool)
func (_AccessContext *AccessContextCaller) HasRole(opts *bind.CallOpts, _role [32]byte, _did [32]byte) (bool, error) {
	var out []interface{}
	err := _AccessContext.contract.Call(opts, &out, "hasRole", _role, _did)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// HasRole is a free data retrieval call binding the contract method 0x0ca075d9.
//
// Solidity: function hasRole(bytes32 _role, bytes32 _did) view returns(bool)
func (_AccessContext *AccessContextSession) HasRole(_role [32]byte, _did [32]byte) (bool, error) {
	return _AccessContext.Contract.HasRole(&_AccessContext.CallOpts, _role, _did)
}

// HasRole is a free data retrieval call binding the contract method 0x0ca075d9.
//
// Solidity: function hasRole(bytes32 _role, bytes32 _did) view returns(bool)
func (_AccessContext *AccessContextCallerSession) HasRole(_role [32]byte, _did [32]byte) (bool, error) {
	return _AccessContext.Contract.HasRole(&_AccessContext.CallOpts, _role, _did)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(bytes32)
func (_AccessContext *AccessContextCaller) Owner(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _AccessContext.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(bytes32)
func (_AccessContext *AccessContextSession) Owner() ([32]byte, error) {
	return _AccessContext.Contract.Owner(&_AccessContext.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(bytes32)
func (_AccessContext *AccessContextCallerSession) Owner() ([32]byte, error) {
	return _AccessContext.Contract.Owner(&_AccessContext.CallOpts)
}

// AssignPermission is a paid mutator transaction binding the contract method 0xd70da68e.
//
// Solidity: function assignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) AssignPermission(opts *bind.TransactOpts, _permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "assignPermission", _permission, _roleContext, _role, _did)
}

// AssignPermission is a paid mutator transaction binding the contract method 0xd70da68e.
//
// Solidity: function assignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) AssignPermission(_permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.AssignPermission(&_AccessContext.TransactOpts, _permission, _roleContext, _role, _did)
}

// AssignPermission is a paid mutator transaction binding the contract method 0xd70da68e.
//
// Solidity: function assignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) AssignPermission(_permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.AssignPermission(&_AccessContext.TransactOpts, _permission, _roleContext, _role, _did)
}

// AssignPolicy is a paid mutator transaction binding the contract method 0xb8bc0fd8.
//
// Solidity: function assignPolicy(bytes32 _policyContext, bytes32 _policy, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) AssignPolicy(opts *bind.TransactOpts, _policyContext [32]byte, _policy [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "assignPolicy", _policyContext, _policy, _role, _did)
}

// AssignPolicy is a paid mutator transaction binding the contract method 0xb8bc0fd8.
//
// Solidity: function assignPolicy(bytes32 _policyContext, bytes32 _policy, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) AssignPolicy(_policyContext [32]byte, _policy [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.AssignPolicy(&_AccessContext.TransactOpts, _policyContext, _policy, _role, _did)
}

// AssignPolicy is a paid mutator transaction binding the contract method 0xb8bc0fd8.
//
// Solidity: function assignPolicy(bytes32 _policyContext, bytes32 _policy, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) AssignPolicy(_policyContext [32]byte, _policy [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.AssignPolicy(&_AccessContext.TransactOpts, _policyContext, _policy, _role, _did)
}

// CheckAdmin is a paid mutator transaction binding the contract method 0xfd9965e6.
//
// Solidity: function checkAdmin(bytes32 _did, address _account) returns(bool)
func (_AccessContext *AccessContextTransactor) CheckAdmin(opts *bind.TransactOpts, _did [32]byte, _account common.Address) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "checkAdmin", _did, _account)
}

// CheckAdmin is a paid mutator transaction binding the contract method 0xfd9965e6.
//
// Solidity: function checkAdmin(bytes32 _did, address _account) returns(bool)
func (_AccessContext *AccessContextSession) CheckAdmin(_did [32]byte, _account common.Address) (*types.Transaction, error) {
	return _AccessContext.Contract.CheckAdmin(&_AccessContext.TransactOpts, _did, _account)
}

// CheckAdmin is a paid mutator transaction binding the contract method 0xfd9965e6.
//
// Solidity: function checkAdmin(bytes32 _did, address _account) returns(bool)
func (_AccessContext *AccessContextTransactorSession) CheckAdmin(_did [32]byte, _account common.Address) (*types.Transaction, error) {
	return _AccessContext.Contract.CheckAdmin(&_AccessContext.TransactOpts, _did, _account)
}

// GrantRole is a paid mutator transaction binding the contract method 0x0888ee4c.
//
// Solidity: function grantRole(bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContext *AccessContextTransactor) GrantRole(opts *bind.TransactOpts, _role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "grantRole", _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// GrantRole is a paid mutator transaction binding the contract method 0x0888ee4c.
//
// Solidity: function grantRole(bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContext *AccessContextSession) GrantRole(_role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContext.Contract.GrantRole(&_AccessContext.TransactOpts, _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// GrantRole is a paid mutator transaction binding the contract method 0x0888ee4c.
//
// Solidity: function grantRole(bytes32 _role, bytes32 _did, bytes32[] _policyContexts, bytes32[] _policies, ((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256))[] _proofs, uint256[20][] _inputs) returns()
func (_AccessContext *AccessContextTransactorSession) GrantRole(_role [32]byte, _did [32]byte, _policyContexts [][32]byte, _policies [][32]byte, _proofs []IPolicyVerifierProof, _inputs [][20]*big.Int) (*types.Transaction, error) {
	return _AccessContext.Contract.GrantRole(&_AccessContext.TransactOpts, _role, _did, _policyContexts, _policies, _proofs, _inputs)
}

// Init is a paid mutator transaction binding the contract method 0x118beb7a.
//
// Solidity: function init(bytes32 initialOwner, bytes32 id, address handler, address didRegistry) returns()
func (_AccessContext *AccessContextTransactor) Init(opts *bind.TransactOpts, initialOwner [32]byte, id [32]byte, handler common.Address, didRegistry common.Address) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "init", initialOwner, id, handler, didRegistry)
}

// Init is a paid mutator transaction binding the contract method 0x118beb7a.
//
// Solidity: function init(bytes32 initialOwner, bytes32 id, address handler, address didRegistry) returns()
func (_AccessContext *AccessContextSession) Init(initialOwner [32]byte, id [32]byte, handler common.Address, didRegistry common.Address) (*types.Transaction, error) {
	return _AccessContext.Contract.Init(&_AccessContext.TransactOpts, initialOwner, id, handler, didRegistry)
}

// Init is a paid mutator transaction binding the contract method 0x118beb7a.
//
// Solidity: function init(bytes32 initialOwner, bytes32 id, address handler, address didRegistry) returns()
func (_AccessContext *AccessContextTransactorSession) Init(initialOwner [32]byte, id [32]byte, handler common.Address, didRegistry common.Address) (*types.Transaction, error) {
	return _AccessContext.Contract.Init(&_AccessContext.TransactOpts, initialOwner, id, handler, didRegistry)
}

// RegisterPermission is a paid mutator transaction binding the contract method 0x6c541a3d.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations) returns()
func (_AccessContext *AccessContextTransactor) RegisterPermission(opts *bind.TransactOpts, _permission [32]byte, _resource [32]byte, _operations []uint8) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "registerPermission", _permission, _resource, _operations)
}

// RegisterPermission is a paid mutator transaction binding the contract method 0x6c541a3d.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations) returns()
func (_AccessContext *AccessContextSession) RegisterPermission(_permission [32]byte, _resource [32]byte, _operations []uint8) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPermission(&_AccessContext.TransactOpts, _permission, _resource, _operations)
}

// RegisterPermission is a paid mutator transaction binding the contract method 0x6c541a3d.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations) returns()
func (_AccessContext *AccessContextTransactorSession) RegisterPermission(_permission [32]byte, _resource [32]byte, _operations []uint8) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPermission(&_AccessContext.TransactOpts, _permission, _resource, _operations)
}

// RegisterPermission0 is a paid mutator transaction binding the contract method 0x9e8e764e.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) RegisterPermission0(opts *bind.TransactOpts, _permission [32]byte, _resource [32]byte, _operations []uint8, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "registerPermission0", _permission, _resource, _operations, _roleContext, _role, _did)
}

// RegisterPermission0 is a paid mutator transaction binding the contract method 0x9e8e764e.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) RegisterPermission0(_permission [32]byte, _resource [32]byte, _operations []uint8, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPermission0(&_AccessContext.TransactOpts, _permission, _resource, _operations, _roleContext, _role, _did)
}

// RegisterPermission0 is a paid mutator transaction binding the contract method 0x9e8e764e.
//
// Solidity: function registerPermission(bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) RegisterPermission0(_permission [32]byte, _resource [32]byte, _operations []uint8, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPermission0(&_AccessContext.TransactOpts, _permission, _resource, _operations, _roleContext, _role, _did)
}

// RegisterPolicy is a paid mutator transaction binding the contract method 0x50ef0554.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) RegisterPolicy(opts *bind.TransactOpts, _policy [32]byte, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "registerPolicy", _policy, _verifier, _did)
}

// RegisterPolicy is a paid mutator transaction binding the contract method 0x50ef0554.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) RegisterPolicy(_policy [32]byte, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPolicy(&_AccessContext.TransactOpts, _policy, _verifier, _did)
}

// RegisterPolicy is a paid mutator transaction binding the contract method 0x50ef0554.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) RegisterPolicy(_policy [32]byte, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPolicy(&_AccessContext.TransactOpts, _policy, _verifier, _did)
}

// RegisterPolicy0 is a paid mutator transaction binding the contract method 0xb51b05a9.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) RegisterPolicy0(opts *bind.TransactOpts, _policy [32]byte, _verifier common.Address, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "registerPolicy0", _policy, _verifier, _role, _did)
}

// RegisterPolicy0 is a paid mutator transaction binding the contract method 0xb51b05a9.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) RegisterPolicy0(_policy [32]byte, _verifier common.Address, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPolicy0(&_AccessContext.TransactOpts, _policy, _verifier, _role, _did)
}

// RegisterPolicy0 is a paid mutator transaction binding the contract method 0xb51b05a9.
//
// Solidity: function registerPolicy(bytes32 _policy, address _verifier, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) RegisterPolicy0(_policy [32]byte, _verifier common.Address, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RegisterPolicy0(&_AccessContext.TransactOpts, _policy, _verifier, _role, _did)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x219adc2e.
//
// Solidity: function renounceOwnership(bytes32 owner_) returns()
func (_AccessContext *AccessContextTransactor) RenounceOwnership(opts *bind.TransactOpts, owner_ [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "renounceOwnership", owner_)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x219adc2e.
//
// Solidity: function renounceOwnership(bytes32 owner_) returns()
func (_AccessContext *AccessContextSession) RenounceOwnership(owner_ [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RenounceOwnership(&_AccessContext.TransactOpts, owner_)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x219adc2e.
//
// Solidity: function renounceOwnership(bytes32 owner_) returns()
func (_AccessContext *AccessContextTransactorSession) RenounceOwnership(owner_ [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RenounceOwnership(&_AccessContext.TransactOpts, owner_)
}

// RevokeRole is a paid mutator transaction binding the contract method 0x7bf67eef.
//
// Solidity: function revokeRole(bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) RevokeRole(opts *bind.TransactOpts, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "revokeRole", _role, _did)
}

// RevokeRole is a paid mutator transaction binding the contract method 0x7bf67eef.
//
// Solidity: function revokeRole(bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) RevokeRole(_role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RevokeRole(&_AccessContext.TransactOpts, _role, _did)
}

// RevokeRole is a paid mutator transaction binding the contract method 0x7bf67eef.
//
// Solidity: function revokeRole(bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) RevokeRole(_role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.RevokeRole(&_AccessContext.TransactOpts, _role, _did)
}

// SetupRole is a paid mutator transaction binding the contract method 0x43aaf7ed.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) SetupRole(opts *bind.TransactOpts, _role [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "setupRole", _role, _policy, _permission, _resource, _operations, _verifier, _did)
}

// SetupRole is a paid mutator transaction binding the contract method 0x43aaf7ed.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) SetupRole(_role [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.SetupRole(&_AccessContext.TransactOpts, _role, _policy, _permission, _resource, _operations, _verifier, _did)
}

// SetupRole is a paid mutator transaction binding the contract method 0x43aaf7ed.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, address _verifier, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) SetupRole(_role [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _verifier common.Address, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.SetupRole(&_AccessContext.TransactOpts, _role, _policy, _permission, _resource, _operations, _verifier, _did)
}

// SetupRole0 is a paid mutator transaction binding the contract method 0xac2b831b.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policyContext, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) SetupRole0(opts *bind.TransactOpts, _role [32]byte, _policyContext [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "setupRole0", _role, _policyContext, _policy, _permission, _resource, _operations, _did)
}

// SetupRole0 is a paid mutator transaction binding the contract method 0xac2b831b.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policyContext, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) SetupRole0(_role [32]byte, _policyContext [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.SetupRole0(&_AccessContext.TransactOpts, _role, _policyContext, _policy, _permission, _resource, _operations, _did)
}

// SetupRole0 is a paid mutator transaction binding the contract method 0xac2b831b.
//
// Solidity: function setupRole(bytes32 _role, bytes32 _policyContext, bytes32 _policy, bytes32 _permission, bytes32 _resource, uint8[] _operations, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) SetupRole0(_role [32]byte, _policyContext [32]byte, _policy [32]byte, _permission [32]byte, _resource [32]byte, _operations []uint8, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.SetupRole0(&_AccessContext.TransactOpts, _role, _policyContext, _policy, _permission, _resource, _operations, _did)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0x6d8c9532.
//
// Solidity: function transferOwnership(bytes32 oldOwner, bytes32 newOwner) returns()
func (_AccessContext *AccessContextTransactor) TransferOwnership(opts *bind.TransactOpts, oldOwner [32]byte, newOwner [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "transferOwnership", oldOwner, newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0x6d8c9532.
//
// Solidity: function transferOwnership(bytes32 oldOwner, bytes32 newOwner) returns()
func (_AccessContext *AccessContextSession) TransferOwnership(oldOwner [32]byte, newOwner [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.TransferOwnership(&_AccessContext.TransactOpts, oldOwner, newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0x6d8c9532.
//
// Solidity: function transferOwnership(bytes32 oldOwner, bytes32 newOwner) returns()
func (_AccessContext *AccessContextTransactorSession) TransferOwnership(oldOwner [32]byte, newOwner [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.TransferOwnership(&_AccessContext.TransactOpts, oldOwner, newOwner)
}

// UnassignPermission is a paid mutator transaction binding the contract method 0x7a8fbbce.
//
// Solidity: function unassignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactor) UnassignPermission(opts *bind.TransactOpts, _permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.contract.Transact(opts, "unassignPermission", _permission, _roleContext, _role, _did)
}

// UnassignPermission is a paid mutator transaction binding the contract method 0x7a8fbbce.
//
// Solidity: function unassignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextSession) UnassignPermission(_permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.UnassignPermission(&_AccessContext.TransactOpts, _permission, _roleContext, _role, _did)
}

// UnassignPermission is a paid mutator transaction binding the contract method 0x7a8fbbce.
//
// Solidity: function unassignPermission(bytes32 _permission, bytes32 _roleContext, bytes32 _role, bytes32 _did) returns()
func (_AccessContext *AccessContextTransactorSession) UnassignPermission(_permission [32]byte, _roleContext [32]byte, _role [32]byte, _did [32]byte) (*types.Transaction, error) {
	return _AccessContext.Contract.UnassignPermission(&_AccessContext.TransactOpts, _permission, _roleContext, _role, _did)
}

// AccessContextOwnershipTransferredIterator is returned from FilterOwnershipTransferred and is used to iterate over the raw logs and unpacked data for OwnershipTransferred events raised by the AccessContext contract.
type AccessContextOwnershipTransferredIterator struct {
	Event *AccessContextOwnershipTransferred // Event containing the contract specifics and raw log

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
func (it *AccessContextOwnershipTransferredIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(AccessContextOwnershipTransferred)
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
		it.Event = new(AccessContextOwnershipTransferred)
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
func (it *AccessContextOwnershipTransferredIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *AccessContextOwnershipTransferredIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// AccessContextOwnershipTransferred represents a OwnershipTransferred event raised by the AccessContext contract.
type AccessContextOwnershipTransferred struct {
	PreviousOwner [32]byte
	NewOwner      [32]byte
	Raw           types.Log // Blockchain specific contextual infos
}

// FilterOwnershipTransferred is a free log retrieval operation binding the contract event 0xcbbb77f62b929125ef27b63e21aa7682e6a2cb1f238a0c221931211b4d1913eb.
//
// Solidity: event OwnershipTransferred(bytes32 indexed previousOwner, bytes32 indexed newOwner)
func (_AccessContext *AccessContextFilterer) FilterOwnershipTransferred(opts *bind.FilterOpts, previousOwner [][32]byte, newOwner [][32]byte) (*AccessContextOwnershipTransferredIterator, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _AccessContext.contract.FilterLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return &AccessContextOwnershipTransferredIterator{contract: _AccessContext.contract, event: "OwnershipTransferred", logs: logs, sub: sub}, nil
}

// WatchOwnershipTransferred is a free log subscription operation binding the contract event 0xcbbb77f62b929125ef27b63e21aa7682e6a2cb1f238a0c221931211b4d1913eb.
//
// Solidity: event OwnershipTransferred(bytes32 indexed previousOwner, bytes32 indexed newOwner)
func (_AccessContext *AccessContextFilterer) WatchOwnershipTransferred(opts *bind.WatchOpts, sink chan<- *AccessContextOwnershipTransferred, previousOwner [][32]byte, newOwner [][32]byte) (event.Subscription, error) {

	var previousOwnerRule []interface{}
	for _, previousOwnerItem := range previousOwner {
		previousOwnerRule = append(previousOwnerRule, previousOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _AccessContext.contract.WatchLogs(opts, "OwnershipTransferred", previousOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(AccessContextOwnershipTransferred)
				if err := _AccessContext.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
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

// ParseOwnershipTransferred is a log parse operation binding the contract event 0xcbbb77f62b929125ef27b63e21aa7682e6a2cb1f238a0c221931211b4d1913eb.
//
// Solidity: event OwnershipTransferred(bytes32 indexed previousOwner, bytes32 indexed newOwner)
func (_AccessContext *AccessContextFilterer) ParseOwnershipTransferred(log types.Log) (*AccessContextOwnershipTransferred, error) {
	event := new(AccessContextOwnershipTransferred)
	if err := _AccessContext.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

