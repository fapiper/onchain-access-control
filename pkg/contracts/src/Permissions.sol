// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./lib/Groups.sol";
import "./Resources.sol";

contract Permissions {
    enum Operation {
        READ,
        WRITE
    }

    // permission id -> resources -> operations
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => Operation))) private permissions;

    function _registerPermissionForResource(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations
    ) private {
        _setPermissionForResource(_permission, _resource, _operations, true);
    }

    function _unregisterPermissionForResource(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations
    ) private {
        _setPermissionForResource(_permission, _resource, _operations, false);
    }

    function _hasPermissionToResource(
        bytes32 _permission,
        bytes32 _resource,
        Operation _operation
    ) private {
        return uint(permissions[_permission][_resource][_operation]) > 0;
    }

    function _hasAnyPermissionToResource(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations
    ) private {
        for (uint256 i = 0; i < _operations.length; i++) {
            if(_hasPermissionToResource(_permission, _resource, _operations[i])){
                return true;
            }
        }
        return false;
    }

    function _setPermissionForResource(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations,
        bool _permit
    ) internal {
        for (uint256 i = 0; i < _operations.length; i++) {
            permissions[_permission][_resource][_operations[i]] = _permit;
        }
    }
}
