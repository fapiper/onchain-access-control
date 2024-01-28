// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./interfaces/IACL.sol";
import "./interfaces/IDIDRegistry.sol";
import "./interfaces/ISessionManager.sol";
import "./interfaces/IPolicyRegistry.sol";
 
contract AC {

    struct Resource {
        bytes32 id;
        string memory owner;
        // context -> role -> set
        mapping(bytes32 => mapping(bytes32 => bool)) roles;
        bool exists;
    }

    mapping(bytes32 => Resource) private resources;

    IACL acl;
    IDIDRegistry didRegistry;
    ISessionManager sessionManager;
    IPolicyRegistry policyRegistry;

    modifier resourceExists(bytes32 _resourceId) {
        require(resources[_resourceId].exists, "resource not found");
        _;
    }

    modifier isOwner(bytes32 _resourceId) {
        require(didRegistry.getController(resources[_resourceId].producer) == msg.sender, "not allowed");
        _;
    }

    constructor(address _acl, address _didRegistry, address _sessionManager, address _policyRegistry){
        acl = IACL(_acl);
        didRegistry = IDIDRegistry(_didRegistry);
        sessionManager = ISessionManager(_sessionManager);
        policyRegistry = IPolicyRegistry(_policyRegistry);
    }

    function registerResourceWithRoles(bytes32 _id, string memory _producer, bytes32[] memory _roles, bytes32[] memory _contexts) public {
        registerResource(_id, _producer);
        addRolesForResource(_id, _roles, _contexts);
    }

    function registerResource(bytes32 _id, string memory _owner) public {
        require(!resources[_id].exists, "resource already exists");
        resources[_id].id = _id;
        resources[_id].exists = true;
        resources[_id]._owner = _owner;
    }

    function getResource(bytes32 _id) public returns (Resource memory) {
        require(resources[_id].exists, "resource not exists");
        return resources[_id];
    }

    function addRolesForResource(bytes32 _resource, bytes32[] memory _roles, bytes32[] memory _contexts) resourceExists(_resourceId) isOwner(_resourceId) public {
        require(_roles.length == _contexts.length, "roles and contexts length not equal");

        for (uint256 i = 0; i < _roles.length; i++) {
            // check if context.role does not yet exist for this resource
            if(resources[_id].roles[_contexts[i]][_roles[i]] == bytes32(0)){
                    resources[_id].roles[_contexts[i]][_roles[i]] = true;
                }
            }
    }

    function removeRolesFromResource(bytes32 _resource, bytes32[] memory _roles, bytes32[] memory _contexts) resourceExists(_resourceId) isOwner(_resourceId) public {
        require(_roles.length == _contexts.length, "roles and contexts length not equal");

        for (uint256 i = 0; i < _roles.length; i++) {
            // check if context.role exists for this resource
            if(resources[_id].roles[_contexts[i]][_roles[i]] != bytes32(0)){
                // TODO remove active sessions
                delete resources[_id].roles[_contexts[i]][_roles[i]];
            }
        }
    }

    function hasPermission(
        bytes32 _context,
        string memory _did,
        bytes32 _resource
    ) override public view returns (uint256) {
        Resource r = getResource(_resource);
        return acl.hasAnyRole(_context, _did, r.roles);
    }

    function authorize(bytes32 _token, string memory _did, bytes32 _role, bytes memory _args) public {
        require(policyRegistry.verifyPolicy(rules[_roleId].policyId, _args), "Not allowed");
        authorize(_token, _did, _role);
    }

    function authorize(bytes32 _token, string memory _did, bytes32 _context, bytes32 _role) public {
        require(acl.hasRole(_context, _did, _role) > 0, "Not allowed");
        sessionManager.setSession(_token, _did, 1000);
    }
}
