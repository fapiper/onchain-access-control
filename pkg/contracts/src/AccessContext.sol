// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./did/DIDOwnable.sol";
import "./context/ContextInstance.sol";
import "./context/IContextInstance.sol";
import "./extension/AccessControlListExtension.sol";
import "./extension/PolicyExtension.sol";
import "./extension/RoleExtension.sol";
import "./extension/PermissionExtension.sol";

contract AccessContext is IContextInstance, DIDOwnable, AccessControlListExtension, PermissionExtension, PolicyExtension, RoleExtension {

    constructor(
        address initialOwner,
        address contextId,
        address contextHandler,
        address didRegistry
    ) DIDOwnable(initialOwner, didRegistry) PolicyExtension(contextId, contextHandler) {}

    /**
     *  @notice         Allows only context admin (owner) or role member for `_role`.
     *
     *  @param _role           Uid of the role within this context.
     */
    modifier onlyOwnerOrRole(bytes32 _role){
        require(_hasRole(_role) && _isDID() || _checkOwner());
        _;
    }

    /**
     *  @notice         Verifies a policy and grants role.
     *  @dev            Caller must be owner or role member.
     *                  Emits {RoleGrant Event}.
     *
     *  @param _role           Uid of the role within this context.
     *  @param _did            DID of the user.
     *  @param _policyContexts Uid of policy contexts.
     *  @param _policies       Uids of the policies of context in `policyContexts` at same index.
     *  @param _args           Verification function arguments.
     */
    function grantRole(
        bytes32 _role,
        bytes32 _did,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies,
        bytes[] memory _args
    ) external {
        bytes32 thisContext = _thisContext();
        require(_hasRoleExpectedPolicyCount(thisContext, _role, _policies.length), "policy len not allowed");
        // TODO with get policies or only policy context sufficient?
        require(_hasRolePolicies(thisContext, _role, _getPolicies(_policyContexts, _policies)), "policy for role not allowed");
        // TODO use policy struct instead of bytes. Or even better (possible?): use policy context and bytes32 id sufficient?
        require(_verifyPolicies(_policyContexts, _policies, _args), "not allowed");
        _grantRole(_role, _did);
    }

    /**
     *  @notice         Checks if a given did is admin.
     *
     *  @param _did         DID of the admin of this context.
     *  @param _account     Address of the DID controller.
     */
    function checkAdmin(
        bytes32 _did,
        address _account
    ) external view returns (bool) {
       return _checkOwner(_did, _account);
    }

    /**
     *  @notice         Revokes a role.
     *  @dev            Caller must be owner or role member.
     *                  Emits {RoleRevoke Event}.
     *
     *  @param _role           Uid of the role within this context.
     *  @param _did            DID of the admin of this context.
     */
    function revokeRole(
        bytes32 _role,
        bytes32 _did
    ) external onlyOwnerOrRole(_role) {
        _revokeRole(_role, _did);
    }

    /**
     *  @notice         Sets up a role for an already registered policy by assigning it to a role, registering
     *                  permissions for a resource and assigning them to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {RoleSetup Event}.
     *
     *  @param _role           Uid of the role within this context.
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _permission     Uid of the permission.
     *  @param _resource       Uid of the resource for which to assign permissions to.
     *  @param _operations     Permitted operations for the resource. Currently either [READ] or [READ, WRITE].
     */
    function setupRole(
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy,
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations
    ) external onlyOwner {
        bytes32 thisContext = _thisContext();
        _assignPolicyToRole(thisContext, _role, _policyContext, _policy);
        _registerPermissionForResource(_permission, _resource, _operations);
        _assignPermissionToRole(thisContext, _role, _permission);
    }

    /**
     *  @notice         Sets up a role by registering a policy and assigning it to a role, registering
     *                  permissions for a resource and assigning them to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {RoleSetup Event}.
     *
     *  @param _role           Uid of the role within this context.
     *  @param _policy         Uid of the policy within this context.
     *  @param _permission     Uid of the permission.
     *  @param _resource       Uid of the resource for which to assign permissions to.
     *  @param _operations     Permitted operations for the resource. Currently either [READ] or [READ, WRITE].
     *  @param _instance       Address of the policy contract instance.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     */
    function setupRole(
        bytes32 _role,
        bytes32 _policy,
        bytes32 _permission,
        bytes32 _resource,
        Operation[] memory _operations,
        address _instance,
        bytes4 _verify
    ) external onlyOwner {
        bytes32 thisContext = _thisContext();
        _registerPolicy(thisContext, _policy, _instance, _verify);
        _assignPolicyToRole(thisContext, _role, thisContext, _policy);
        _registerPermissionForResource(_permission, _resource, _operations);
        _assignPermissionToRole(thisContext, _role, thisContext, _permission);
    }

    /**
     *  @notice         Registers a policy without assigning it to a role.
     *  @dev            Caller must have owner role.
     *                  Emits {PolicyRegistered Event}.
     *
     *  @param _policy         Uid of the policy within this context.
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
     *  @param _policy         Uid of the policy within this context`.
     *  @param _contract       Address of the policy contract.
     *  @param _verify         Function identifier of the policy verification function of `_contract`.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function registerPolicy(
        bytes32 _policy,
        address _contract,
        bytes4 _verify,
        bytes32 _role
    ) external onlyOwner {
        bytes32 thisContext = _thisContext();
        _registerPolicy(_policy, _contract, _verify);
        _assignPolicyToRole(thisContext, _role, thisContext, _policy);
    }

    /**
     *  @notice         Get a policy from own or cross context.
     *
     *  @param _context        Uid of the policy context.
     *  @param _id             Uid of the role within `_context`.
     *
     * @return policy          The policy struct of `_context`
     */
    function getPolicy(
        bytes32 _context,
        bytes32 _id
    ) public returns (Policy memory) {
        return _getPolicy(_context, _id);
    }

    /**
     *  @notice         Get policies from own or cross context.
     *
     *  @param _contexts        Uids of the policy contexts.
     *  @param _ids             Uids of the roles within `_contexts`.
     *
     * @return policies          The policy struct array of `_contexts`
     */
    function getPolicies(
        bytes32[] memory _contexts,
        bytes32[] memory _ids
    ) external returns (Policy[] memory policies) {
        return _getPolicies(_contexts, _ids);
    }

    /**
     *  @notice         Assigns an existing policy from own or cross-context to a role from own context.
     *  @dev            Caller must have owner role.
     *                  Emits {PolicyAssigned Event}.
     *
     *  @param _policyContext  Uid of the access context for the policy.
     *  @param _policy         Uid of the policy within `_policyContext`.
     *  @param _role           Uid of the role within `_roleContext`.
     */
    function assignPolicy(
        bytes32 _policyContext,
        bytes32 _policy,
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
    ) external onlyOwner {
        _registerPermissionForResource(_permission, _resource, _operations);
        _assignPermissionToRole(_roleContext, _role, _permission);
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
        _assignPermissionToRole(_roleContext, _role, _permission);
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
        _unassignPermissionToRole(_roleContext, _role, _permission);
    }
}
