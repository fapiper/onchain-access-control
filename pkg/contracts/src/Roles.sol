// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract Roles {
    // role -> did
    mapping(bytes32 => string) private hasRole;

    function _grantRole(
        bytes32 _role,
        string memory _did
    ) private {
        hasRole[_role] = _did;
    }

    function _revokeRole(
        bytes32 _role,
        string memory _did
    ) private {
        delete hasRole[_role] = _did;
    }

    function _hasRole(
        bytes32 _role,
        string memory _did
    ) private view returns (bool){
        return hasRole[_role][_did] != "";
    }
}
