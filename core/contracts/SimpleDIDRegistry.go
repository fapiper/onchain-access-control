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

// SimpleDIDRegistryMetaData contains all meta data concerning the SimpleDIDRegistry contract.
var SimpleDIDRegistryMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"bytes32[]\",\"name\":\"_identities\",\"type\":\"bytes32[]\"},{\"internalType\":\"address[]\",\"name\":\"_controllers\",\"type\":\"address[]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"controller\",\"type\":\"address\"}],\"name\":\"DIDControllerChanged\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"controller\",\"type\":\"address\"}],\"name\":\"addController\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"newController\",\"type\":\"address\"}],\"name\":\"changeController\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"changed\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"controllers\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"}],\"name\":\"getController\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"}],\"name\":\"getControllers\",\"outputs\":[{\"internalType\":\"address[]\",\"name\":\"\",\"type\":\"address[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"actor\",\"type\":\"address\"}],\"name\":\"isController\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"identity\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"controller\",\"type\":\"address\"}],\"name\":\"removeController\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// SimpleDIDRegistryABI is the input ABI used to generate the binding from.
// Deprecated: Use SimpleDIDRegistryMetaData.ABI instead.
var SimpleDIDRegistryABI = SimpleDIDRegistryMetaData.ABI

// SimpleDIDRegistry is an auto generated Go binding around an Ethereum contract.
type SimpleDIDRegistry struct {
	SimpleDIDRegistryCaller     // Read-only binding to the contract
	SimpleDIDRegistryTransactor // Write-only binding to the contract
	SimpleDIDRegistryFilterer   // Log filterer for contract events
}

// SimpleDIDRegistryCaller is an auto generated read-only Go binding around an Ethereum contract.
type SimpleDIDRegistryCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SimpleDIDRegistryTransactor is an auto generated write-only Go binding around an Ethereum contract.
type SimpleDIDRegistryTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SimpleDIDRegistryFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type SimpleDIDRegistryFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// SimpleDIDRegistrySession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type SimpleDIDRegistrySession struct {
	Contract     *SimpleDIDRegistry // Generic contract binding to set the session for
	CallOpts     bind.CallOpts      // Call options to use throughout this session
	TransactOpts bind.TransactOpts  // Transaction auth options to use throughout this session
}

// SimpleDIDRegistryCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type SimpleDIDRegistryCallerSession struct {
	Contract *SimpleDIDRegistryCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts            // Call options to use throughout this session
}

// SimpleDIDRegistryTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type SimpleDIDRegistryTransactorSession struct {
	Contract     *SimpleDIDRegistryTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts            // Transaction auth options to use throughout this session
}

// SimpleDIDRegistryRaw is an auto generated low-level Go binding around an Ethereum contract.
type SimpleDIDRegistryRaw struct {
	Contract *SimpleDIDRegistry // Generic contract binding to access the raw methods on
}

// SimpleDIDRegistryCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type SimpleDIDRegistryCallerRaw struct {
	Contract *SimpleDIDRegistryCaller // Generic read-only contract binding to access the raw methods on
}

// SimpleDIDRegistryTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type SimpleDIDRegistryTransactorRaw struct {
	Contract *SimpleDIDRegistryTransactor // Generic write-only contract binding to access the raw methods on
}

// NewSimpleDIDRegistry creates a new instance of SimpleDIDRegistry, bound to a specific deployed contract.
func NewSimpleDIDRegistry(address common.Address, backend bind.ContractBackend) (*SimpleDIDRegistry, error) {
	contract, err := bindSimpleDIDRegistry(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &SimpleDIDRegistry{SimpleDIDRegistryCaller: SimpleDIDRegistryCaller{contract: contract}, SimpleDIDRegistryTransactor: SimpleDIDRegistryTransactor{contract: contract}, SimpleDIDRegistryFilterer: SimpleDIDRegistryFilterer{contract: contract}}, nil
}

// NewSimpleDIDRegistryCaller creates a new read-only instance of SimpleDIDRegistry, bound to a specific deployed contract.
func NewSimpleDIDRegistryCaller(address common.Address, caller bind.ContractCaller) (*SimpleDIDRegistryCaller, error) {
	contract, err := bindSimpleDIDRegistry(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &SimpleDIDRegistryCaller{contract: contract}, nil
}

// NewSimpleDIDRegistryTransactor creates a new write-only instance of SimpleDIDRegistry, bound to a specific deployed contract.
func NewSimpleDIDRegistryTransactor(address common.Address, transactor bind.ContractTransactor) (*SimpleDIDRegistryTransactor, error) {
	contract, err := bindSimpleDIDRegistry(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &SimpleDIDRegistryTransactor{contract: contract}, nil
}

// NewSimpleDIDRegistryFilterer creates a new log filterer instance of SimpleDIDRegistry, bound to a specific deployed contract.
func NewSimpleDIDRegistryFilterer(address common.Address, filterer bind.ContractFilterer) (*SimpleDIDRegistryFilterer, error) {
	contract, err := bindSimpleDIDRegistry(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &SimpleDIDRegistryFilterer{contract: contract}, nil
}

// bindSimpleDIDRegistry binds a generic wrapper to an already deployed contract.
func bindSimpleDIDRegistry(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := SimpleDIDRegistryMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_SimpleDIDRegistry *SimpleDIDRegistryRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _SimpleDIDRegistry.Contract.SimpleDIDRegistryCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_SimpleDIDRegistry *SimpleDIDRegistryRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.SimpleDIDRegistryTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_SimpleDIDRegistry *SimpleDIDRegistryRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.SimpleDIDRegistryTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _SimpleDIDRegistry.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.contract.Transact(opts, method, params...)
}

// Changed is a free data retrieval call binding the contract method 0xf96d0f9f.
//
// Solidity: function changed(address ) view returns(uint256)
func (_SimpleDIDRegistry *SimpleDIDRegistryCaller) Changed(opts *bind.CallOpts, arg0 common.Address) (*big.Int, error) {
	var out []interface{}
	err := _SimpleDIDRegistry.contract.Call(opts, &out, "changed", arg0)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Changed is a free data retrieval call binding the contract method 0xf96d0f9f.
//
// Solidity: function changed(address ) view returns(uint256)
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) Changed(arg0 common.Address) (*big.Int, error) {
	return _SimpleDIDRegistry.Contract.Changed(&_SimpleDIDRegistry.CallOpts, arg0)
}

// Changed is a free data retrieval call binding the contract method 0xf96d0f9f.
//
// Solidity: function changed(address ) view returns(uint256)
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerSession) Changed(arg0 common.Address) (*big.Int, error) {
	return _SimpleDIDRegistry.Contract.Changed(&_SimpleDIDRegistry.CallOpts, arg0)
}

// Controllers is a free data retrieval call binding the contract method 0x3d2c5803.
//
// Solidity: function controllers(bytes32 , uint256 ) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistryCaller) Controllers(opts *bind.CallOpts, arg0 [32]byte, arg1 *big.Int) (common.Address, error) {
	var out []interface{}
	err := _SimpleDIDRegistry.contract.Call(opts, &out, "controllers", arg0, arg1)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Controllers is a free data retrieval call binding the contract method 0x3d2c5803.
//
// Solidity: function controllers(bytes32 , uint256 ) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) Controllers(arg0 [32]byte, arg1 *big.Int) (common.Address, error) {
	return _SimpleDIDRegistry.Contract.Controllers(&_SimpleDIDRegistry.CallOpts, arg0, arg1)
}

// Controllers is a free data retrieval call binding the contract method 0x3d2c5803.
//
// Solidity: function controllers(bytes32 , uint256 ) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerSession) Controllers(arg0 [32]byte, arg1 *big.Int) (common.Address, error) {
	return _SimpleDIDRegistry.Contract.Controllers(&_SimpleDIDRegistry.CallOpts, arg0, arg1)
}

// GetController is a free data retrieval call binding the contract method 0x8f1815b2.
//
// Solidity: function getController(bytes32 identity) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistryCaller) GetController(opts *bind.CallOpts, identity [32]byte) (common.Address, error) {
	var out []interface{}
	err := _SimpleDIDRegistry.contract.Call(opts, &out, "getController", identity)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetController is a free data retrieval call binding the contract method 0x8f1815b2.
//
// Solidity: function getController(bytes32 identity) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) GetController(identity [32]byte) (common.Address, error) {
	return _SimpleDIDRegistry.Contract.GetController(&_SimpleDIDRegistry.CallOpts, identity)
}

// GetController is a free data retrieval call binding the contract method 0x8f1815b2.
//
// Solidity: function getController(bytes32 identity) view returns(address)
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerSession) GetController(identity [32]byte) (common.Address, error) {
	return _SimpleDIDRegistry.Contract.GetController(&_SimpleDIDRegistry.CallOpts, identity)
}

// GetControllers is a free data retrieval call binding the contract method 0x8eb2b820.
//
// Solidity: function getControllers(bytes32 identity) view returns(address[])
func (_SimpleDIDRegistry *SimpleDIDRegistryCaller) GetControllers(opts *bind.CallOpts, identity [32]byte) ([]common.Address, error) {
	var out []interface{}
	err := _SimpleDIDRegistry.contract.Call(opts, &out, "getControllers", identity)

	if err != nil {
		return *new([]common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new([]common.Address)).(*[]common.Address)

	return out0, err

}

// GetControllers is a free data retrieval call binding the contract method 0x8eb2b820.
//
// Solidity: function getControllers(bytes32 identity) view returns(address[])
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) GetControllers(identity [32]byte) ([]common.Address, error) {
	return _SimpleDIDRegistry.Contract.GetControllers(&_SimpleDIDRegistry.CallOpts, identity)
}

// GetControllers is a free data retrieval call binding the contract method 0x8eb2b820.
//
// Solidity: function getControllers(bytes32 identity) view returns(address[])
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerSession) GetControllers(identity [32]byte) ([]common.Address, error) {
	return _SimpleDIDRegistry.Contract.GetControllers(&_SimpleDIDRegistry.CallOpts, identity)
}

// IsController is a free data retrieval call binding the contract method 0x2427473b.
//
// Solidity: function isController(bytes32 identity, address actor) view returns(bool)
func (_SimpleDIDRegistry *SimpleDIDRegistryCaller) IsController(opts *bind.CallOpts, identity [32]byte, actor common.Address) (bool, error) {
	var out []interface{}
	err := _SimpleDIDRegistry.contract.Call(opts, &out, "isController", identity, actor)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsController is a free data retrieval call binding the contract method 0x2427473b.
//
// Solidity: function isController(bytes32 identity, address actor) view returns(bool)
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) IsController(identity [32]byte, actor common.Address) (bool, error) {
	return _SimpleDIDRegistry.Contract.IsController(&_SimpleDIDRegistry.CallOpts, identity, actor)
}

// IsController is a free data retrieval call binding the contract method 0x2427473b.
//
// Solidity: function isController(bytes32 identity, address actor) view returns(bool)
func (_SimpleDIDRegistry *SimpleDIDRegistryCallerSession) IsController(identity [32]byte, actor common.Address) (bool, error) {
	return _SimpleDIDRegistry.Contract.IsController(&_SimpleDIDRegistry.CallOpts, identity, actor)
}

// AddController is a paid mutator transaction binding the contract method 0x854a03dc.
//
// Solidity: function addController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactor) AddController(opts *bind.TransactOpts, identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.contract.Transact(opts, "addController", identity, controller)
}

// AddController is a paid mutator transaction binding the contract method 0x854a03dc.
//
// Solidity: function addController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) AddController(identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.AddController(&_SimpleDIDRegistry.TransactOpts, identity, controller)
}

// AddController is a paid mutator transaction binding the contract method 0x854a03dc.
//
// Solidity: function addController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactorSession) AddController(identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.AddController(&_SimpleDIDRegistry.TransactOpts, identity, controller)
}

// ChangeController is a paid mutator transaction binding the contract method 0x55161467.
//
// Solidity: function changeController(bytes32 identity, address newController) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactor) ChangeController(opts *bind.TransactOpts, identity [32]byte, newController common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.contract.Transact(opts, "changeController", identity, newController)
}

// ChangeController is a paid mutator transaction binding the contract method 0x55161467.
//
// Solidity: function changeController(bytes32 identity, address newController) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) ChangeController(identity [32]byte, newController common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.ChangeController(&_SimpleDIDRegistry.TransactOpts, identity, newController)
}

// ChangeController is a paid mutator transaction binding the contract method 0x55161467.
//
// Solidity: function changeController(bytes32 identity, address newController) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactorSession) ChangeController(identity [32]byte, newController common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.ChangeController(&_SimpleDIDRegistry.TransactOpts, identity, newController)
}

// RemoveController is a paid mutator transaction binding the contract method 0xfe1a8487.
//
// Solidity: function removeController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactor) RemoveController(opts *bind.TransactOpts, identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.contract.Transact(opts, "removeController", identity, controller)
}

// RemoveController is a paid mutator transaction binding the contract method 0xfe1a8487.
//
// Solidity: function removeController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistrySession) RemoveController(identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.RemoveController(&_SimpleDIDRegistry.TransactOpts, identity, controller)
}

// RemoveController is a paid mutator transaction binding the contract method 0xfe1a8487.
//
// Solidity: function removeController(bytes32 identity, address controller) returns()
func (_SimpleDIDRegistry *SimpleDIDRegistryTransactorSession) RemoveController(identity [32]byte, controller common.Address) (*types.Transaction, error) {
	return _SimpleDIDRegistry.Contract.RemoveController(&_SimpleDIDRegistry.TransactOpts, identity, controller)
}

// SimpleDIDRegistryDIDControllerChangedIterator is returned from FilterDIDControllerChanged and is used to iterate over the raw logs and unpacked data for DIDControllerChanged events raised by the SimpleDIDRegistry contract.
type SimpleDIDRegistryDIDControllerChangedIterator struct {
	Event *SimpleDIDRegistryDIDControllerChanged // Event containing the contract specifics and raw log

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
func (it *SimpleDIDRegistryDIDControllerChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(SimpleDIDRegistryDIDControllerChanged)
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
		it.Event = new(SimpleDIDRegistryDIDControllerChanged)
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
func (it *SimpleDIDRegistryDIDControllerChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *SimpleDIDRegistryDIDControllerChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// SimpleDIDRegistryDIDControllerChanged represents a DIDControllerChanged event raised by the SimpleDIDRegistry contract.
type SimpleDIDRegistryDIDControllerChanged struct {
	Identity   [32]byte
	Controller common.Address
	Raw        types.Log // Blockchain specific contextual infos
}

// FilterDIDControllerChanged is a free log retrieval operation binding the contract event 0xcceb596a34a057e94b864e7a5aa0664ebb466c37b4d90914b2b3e1b49afa2d7b.
//
// Solidity: event DIDControllerChanged(bytes32 identity, address controller)
func (_SimpleDIDRegistry *SimpleDIDRegistryFilterer) FilterDIDControllerChanged(opts *bind.FilterOpts) (*SimpleDIDRegistryDIDControllerChangedIterator, error) {

	logs, sub, err := _SimpleDIDRegistry.contract.FilterLogs(opts, "DIDControllerChanged")
	if err != nil {
		return nil, err
	}
	return &SimpleDIDRegistryDIDControllerChangedIterator{contract: _SimpleDIDRegistry.contract, event: "DIDControllerChanged", logs: logs, sub: sub}, nil
}

// WatchDIDControllerChanged is a free log subscription operation binding the contract event 0xcceb596a34a057e94b864e7a5aa0664ebb466c37b4d90914b2b3e1b49afa2d7b.
//
// Solidity: event DIDControllerChanged(bytes32 identity, address controller)
func (_SimpleDIDRegistry *SimpleDIDRegistryFilterer) WatchDIDControllerChanged(opts *bind.WatchOpts, sink chan<- *SimpleDIDRegistryDIDControllerChanged) (event.Subscription, error) {

	logs, sub, err := _SimpleDIDRegistry.contract.WatchLogs(opts, "DIDControllerChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(SimpleDIDRegistryDIDControllerChanged)
				if err := _SimpleDIDRegistry.contract.UnpackLog(event, "DIDControllerChanged", log); err != nil {
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

// ParseDIDControllerChanged is a log parse operation binding the contract event 0xcceb596a34a057e94b864e7a5aa0664ebb466c37b4d90914b2b3e1b49afa2d7b.
//
// Solidity: event DIDControllerChanged(bytes32 identity, address controller)
func (_SimpleDIDRegistry *SimpleDIDRegistryFilterer) ParseDIDControllerChanged(log types.Log) (*SimpleDIDRegistryDIDControllerChanged, error) {
	event := new(SimpleDIDRegistryDIDControllerChanged)
	if err := _SimpleDIDRegistry.contract.UnpackLog(event, "DIDControllerChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

