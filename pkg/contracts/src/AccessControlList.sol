// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./Permissions.sol";
import "./Roles.sol";

contract AccessControlList {

    // role contexts -> role ids -> count policies
    mapping(bytes32 => mapping(bytes32 => bytes32)) private policyCount;
    // role context -> role -> policy context -> policy ids
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bytes32))) private policies;
    // role context -> role -> permission context -> permission ids
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bytes32))) private permissions;

    function _assignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissionContexts,
        bytes32[] memory _permissions
    ) private {
        for (uint256 i = 0; i < _permissionContexts.length; i++) {
            _assignPermissionToRole(_roleContext, _role, _permissionContexts[i], _permissions[i]);
        }
    }

    function _assignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permissionContext,
        bytes32 _permission
    ) private {
        permissions[_roleContext][_role][_permissionContext] = _permission;
    }

    function _unassignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissionContexts,
        bytes32[] memory _permissions
    ) private {
        for (uint256 i = 0; i < _permissionContexts.length; i++) {
            _unassignPermissionForRole(_roleContext, _role, _permissionContexts[i], _permissions[i]);
        }
    }

    function _unassignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permissionContext,
        bytes32 _permission
    ) private {
        delete permissions[_roleContext][_role][_permissionContext][_permission];
    }

    function _assignPoliciesToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies
    ) private {
        for (uint256 i = 0; i < policyLen; i++) {
            _assignPolicyToRole(_roleContext, _role, _policyContexts[i], _permissions[i]);
        }
    }

    function _assignPolicyToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy
    ) private {
        policies[_roleContext][_role][_policyContext] = _policy;
        policyCount[_roleContext][_role] += 1;
    }

    function _unassignPoliciesToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies
    ) private {
        for (uint256 i = 0; i < policyLen; i++) {
            _unassignPolicyToRole(_roleContext, _role, _policyContexts[i], policies[i]);
        }
    }

    function _unassignPolicyToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy
    ) private {
        require(_getPolicyCount(_roleContext, _role) > 0, "no policy found for role");
        delete policies[_role][_policyContext][_policy];
        policyCount[_roleContext][_role] -= 1;
    }

    function _getPolicyCount(
        bytes32 _roleContext,
        bytes32 _role
    ) private view returns (uint256) {
        return policyCount[_roleContext][_role];
    }

/*
    function _context(bytes32 _context) internal view returns (IAccessContext) {
        return _contextHandler().getAccessContext(_context);
    }

    function _contextHandler() internal view returns (IContextHandler) {
        return "";
    }
*/

}
