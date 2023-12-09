// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IACL.sol";
import "./interfaces/IDIDRegistry.sol";
import "./interfaces/ISessionManager.sol";
import "./interfaces/IPolicyRegistry.sol";
 
contract AccessControl {

    struct Rule {
        bytes32 policyId;
        bytes32 roleId;
        bytes32 context;
        uint256 sessionDuration;
        bool exists;
    }

    IACL acl;
    IDIDRegistry didRegistry;
    ISessionManager sessionManager;
    IPolicyRegistry policyRegistry;

    mapping(bytes32 => Rule) private rules;

    modifier ruleExists(bytes32 _roleId) {
        require(rules[_roleId].exists, "Rule not found for role");
        _;
    }

    modifier isPolicyController(bytes32 _policyId) {
        require(policyRegistry.isController(_policyId, msg.sender), "Rule not found for role");
        _;
    }

    constructor(address _acl, address _didRegistry, address _sessionManager, address _policyRegistry){
        acl = IACL(_acl);
        didRegistry = IDIDRegistry(_didRegistry);
        sessionManager = ISessionManager(_sessionManager);
        policyRegistry = IPolicyRegistry(_policyRegistry);
    }

    function addRule(bytes32 _roleId, bytes32 _policyId, bytes32 _context) ruleExists(_roleId) isPolicyController(rules[_roleId].policyId) public returns (Rule memory) {
        require(!rules[_roleId].exists, "rule already exists");
        rules[_roleId] = Rule(_policyId, _roleId, _context, 10000, true);
        return rules[_roleId];
    }

    function removeRule(bytes32 _roleId) ruleExists(_roleId) isPolicyController(rules[_roleId].policyId) public {
        delete rules[_roleId];
    }

    function authorize(bytes32 _token, string memory _did, bytes32 _roleId, bytes memory _args) ruleExists(_roleId) public {
        require(policyRegistry.verifyPolicy(rules[_roleId].policyId, _args), "Not allowed");
        authorize(_token, _did, _roleId);
    }

    function authorize(bytes32 _token, string memory _did, bytes32 _roleId) ruleExists(_roleId) public {
        require(acl.hasRole(rules[_roleId].context, _did, _roleId) > 0, "Not allowed");
        sessionManager.setSession(_token, _did, rules[_roleId].sessionDuration);
    }
}
