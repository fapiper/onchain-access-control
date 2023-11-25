// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IACL.sol";
import "./interfaces/ISessionManager.sol";
import "./interfaces/IPolicyRegistry.sol";

contract AccessControl {

    struct RoleConfig {
        bytes policyId;
        uint256 duration;
    }

    IACL acl;
    ISessionManager sessionManager;
    IPolicyRegistry policyRegistry;

    mapping(bytes => RoleConfig) private configs;

    constructor(address _acl, address _sessionManager, address _policyRegistry){
        acl = IACL(_acl);
        sessionManager = ISessionManager(_sessionManager);
        policyRegistry = IPolicyRegistry(_policyRegistry);
    }

    function authorize(bytes memory _token, bytes memory _roleId) public view returns (SessionInfo) {
        require(policyRegistry.verifyPolicy(configs[_roleId].policyId, _args), "Not allowed");
        SessionInfo memory session = sessionManager.setSession(_token, configs[_roleId].duration);
        acl.assignRole(bytes(""), session.token, _roleId);
        return session;
    }

    function isTokenValid(bytes memory _token) public view returns (SessionInfo) {
        bytes memory session = sessionManager.getSession(_token);
        return sessionManager.isSessionValid(session) && hasRoleByToken(_token);
    }

    function hasRoleByToken(bytes memory _token) public view returns (bool) {
        return acl.hasRole(bytes(""), _token, configs[_token]);
    }
}
