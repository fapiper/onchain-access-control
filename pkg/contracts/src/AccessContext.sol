// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./did/DIDOwnable.sol";
import "./Policies.sol";
import "./Roles.sol";
import "./AccessControlList.sol";

contract AccessContext is DIDOwnable, AccessControlList, Policies, Roles {

    constructor(
        address initialOwner,
        address didRegistry
    ) DIDOwnable(initialOwner, didRegistry) {}

    modifier onlyOwnerOrRole(bytes32 _role){
        require(_hasRole(_role) && _isDID() || _checkOwner());
        _;
    }

    function grantRole(
        bytes32 _role,
        string memory _did,
        bytes32[] memory _policies,
        bytes[] memory _args
    ) external {
        require(_verifyPolicies(_policies, _args), "not allowed");
        _grantRole(_role, _did);
    }

    function revokeRole(
        bytes32 _role,
        string memory _did
    ) external onlyAdminOrRole(_role) {
        _revokeRole(_role, _did);
    }

    /**
     *  @notice         Sets up a role by registering a policy and assigning it to a role, registering
     *                  permissions for a resource and assigning them to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {RoleSetup Event}.
     *
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _contract       Address of the policy contract.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     */
    function setupRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy,
        address _contract,
        bytes4 _verify
    ) external onlyOwner {
        _registerPolicy(_policy, _contract, _verify);
        _assignPolicyToRole(_roleContext, _role, _policyContexts, _policies);
        _registerPermissionForResource();
        _assignPermissionToRole();
    }

    /**
     *  @notice         Sets up a role by registering a policy and assigning it to a role, registering
     *                  permissions for a resource and assigning them to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {RoleSetup Event}.
     *
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _contract       Address of the policy contract.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     */
    function registerRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy,
        address _contract,
        bytes4 _verify
    ) external onlyOwner {
        bytes32 thisContext = _thisContext();
        _registerPolicy(_policy, _contract, _verify);
        _assignPolicyToRole(thisContext, _role, thisContext, _policies);
        _registerPermissionForResource(_permission, _resource, _operations);
        _assignPermissionToRole(thisContext, _role, thisContext, _permission);
    }

    /**
     *  @notice         Registers a policy without assigning it to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PolicyRegistered Event}.
     *
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _contract       Address of the policy contract.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     */
    function registerPolicy(
        bytes32 _policy,
        address _contract,
        bytes4 _verify
    ) external onlyOwner {
        _registerPolicy(_policy, _contract, _verify);
    }


    /**
     *  @notice         Registers a policy and assigns it to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PolicyRegistered Event}.
     *
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _contract       Address of the policy contract.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function registerPolicy(
        bytes32 _policyContext,
        bytes32 _policy,
        address _contract,
        bytes4 _verify,
        bytes32 _roleContext,
        bytes32 _role
    ) external overwrite onlyOwner {
        _registerPolicy(_policy, _contract, _verify);
        _assignPolicyToRole(_thisContext(), _role, _policyContext, _policy);
    }

    function unregisterPolicy(
        bytes32 _id
    ) external onlyOwner {
        _unregisterPolicy(_id);
    }

    function verifyPolicy(
        bytes32 _id,
        bytes memory _args
    ) external returns (bool) {
        return _verifyPolicy(_id, _args);
    }

    /**
     *  @notice         Assigns an existing policy from own or cross-context to a role from own context. TODO role only from own context
     *  @dev            Caller must have owner role.
     *                  Emits {PolicyAssigned Event}.
     *
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function assignPolicy(
        bytes32 _policyContext,
        bytes32 _policy,
        bytes32 _roleContext,
        bytes32 _role
    ) external onlyOwner {
        _assignPolicyToRole(_thisContext(), _role, _policyContext, _policy);
    }

    /**
     *  @notice         Registers a new permission by assigning a resource and operations. Does not assign a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PermissionRegistered Event}.
     *
     *  @param _permission     Uid of the permission.
     *  @param _resource       Uid of the resource for which to assign permissions to.
     *  @param _operations     Permitted operations for the resource. Currently either [READ] or [READ, WRITE].
     */
    function registerPermission(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations
    ) external {
        _registerPermissionForResource(_permission, _resource, _operations);
    }

    /**
     *  @notice         Registers a new permission by assigning a resource, operations and a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PermissionRegistered Event}.
     *
     *  @param _permission     Uid of the permission.
     *  @param _resource       Uid of the resource for which to assign permissions to.
     *  @param _operations     Permitted operations for the resource. Currently either [READ] or [READ, WRITE].
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function registerPermission(
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations,
        bytes32 _roleContext,
        bytes32 _role
    ) external overwrite onlyOwner {
        _registerPermissionForResource(_permission, _resource, _operations);
        _assignPermissionToRole(_roleContext, _role, _thisContext(), _permission);
    }

    /**
     *  @notice         Assigns an existing permission to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PermissionAssigned Event}.
     *
     *  @param _permission     Uid of the permission.
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function assignPermission(
        bytes32 _permission,
        bytes32 _roleContext,
        bytes32 _role
    ) external onlyOwner {
        _assignPermissionToRole(_roleContext, _role, _thisContext(), _permission);
    }

    /**
     *  @notice         Remove permission assignment to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PermissionUnassigned Event}.
     *
     *  @param _permission     Uid of the permission.
     *  @param _roleContext    Uid of the access context for the role.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function unassignPermission(
        bytes32 _permission,
        bytes32 _roleContext,
        bytes32 _role
    ) external onlyOwner {
        _unassignPermissionToRole(_roleContext, _role, _thisContext(), _permission);
    }
}
