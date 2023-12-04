// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IACL.sol";
import "./interfaces/ISessionManager.sol";
import "./interfaces/IPolicyManager.sol";

contract AccessManager {

    struct Rule {
        bytes32 policyId;
        bytes32 roleId;
        bytes32 context;
        uint256 sessionDuration;
        bool exists;
    }

    IACL acl;
    ISessionManager sessionManager;
    IPolicyManager policyRegistry;

    mapping(bytes32 => Rule) private rules;

    modifier assertRuleExists(bytes32 memory _roleId) {
        require(rules[_roleId].exists, "Rule not found for role");
        _;
    }

    constructor(address _acl, address _sessionManager, address _policyRegistry){
        acl = IACL(_acl);
        sessionManager = ISessionManager(_sessionManager);
        policyRegistry = IPolicyManager(_policyRegistry);
    }

    function addRule(bytes32 memory _roleId, bytes32 memory _policyId, bytes32 memory _context) assertRuleExists(_roleId) public view returns (Rule) {
        require(policyRegistry.isPolicyAdmin(msg.sender), "Not allowed");
        Rule storage rule = Rule(_policyId, _roleId, _context, 10000, true);
        rules[_roleId] = rule;
        return rule;
    }

    function removeRule(bytes32 memory _roleId) assertRuleExists(_roleId) public {
        require(policyRegistry.isPolicyAdmin(msg.sender), "Not allowed");
        delete rules[_roleId];
    }

    function authorize(bytes memory _token, bytes32 memory _did, bytes32 memory _roleId, bytes memory _args) assertRuleExists(_roleId) public returns (SessionInfo) {
        require(policyRegistry.verifyPolicy(rules[_roleId].policyId, _args), "Not allowed");
        acl.assignRole(rules[_roleId].context, _did, _roleId);
        return sessionManager.setSession(_token, _did, configs[_roleId].duration);
    }

    function authorize(bytes memory _token, bytes32 memory _roleId) assertRuleExists(_roleId) public returns (SessionInfo) {
        require(acl.hasRole(rules[_roleId].context, msg.sender, _roleId), "Not allowed");
        return sessionManager.setSession(_token, _did, configs[_roleId].duration);
    }

    function revert(bytes memory _token, bytes32 memory _roleId) assertRuleExists(_roleId) public {
        acl.unassignRole(rules[_roleId].context, msg.sender, _roleId);
        sessionManager.revertSession(_token);
    }
}
