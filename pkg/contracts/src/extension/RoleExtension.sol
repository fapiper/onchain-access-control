// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

contract RoleExtension {
    // role -> did
    mapping(bytes32 => string) private hasRole;

    function _grantRole(
        bytes32 _role,
        bytes32 _did
    ) internal {
        hasRole[_role] = _did;
    }

    function _revokeRole(
        bytes32 _role,
        bytes32 _did
    ) internal {
        delete hasRole[_role] = _did;
    }

    function _hasRole(
        bytes32 _role,
        bytes32 _did
    ) internal view returns (bool){
        return hasRole[_role][_did] != "";
    }
}
