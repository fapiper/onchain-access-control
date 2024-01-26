// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./Permissions.sol";
import "./Roles.sol";

contract AccessControlList {

    // role context -> roles -> count policies
    mapping(bytes32 => mapping(bytes32 => bytes32)) private policyCount;
    // role context -> roles -> policy context -> policies
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bytes32))) private policies;
    // role context -> roles -> permissions
    mapping(bytes32 => mapping(bytes32 => bytes32)) private permissions;

    function _assignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissions
    ) private {
        for (uint256 i = 0; i < _permissions.length; i++) {
            _assignPermissionToRole(_roleContext, _role, _permissions[i]);
        }
    }

    function _assignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permission
    ) private {
        permissions[_roleContext][_role] = _permission;
    }

    function _unassignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissions
    ) private {
        for (uint256 i = 0; i < _permissions.length; i++) {
            _unassignPermissionForRole(_roleContext, _role, _permissions[i]);
        }
    }

    function _unassignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permission
    ) private {
        delete permissions[_roleContext][_role][_permission];
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

    function _hasRolePolicies(
        bytes32 _roleContext,
        bytes32 _role,
        Policy[] memory _policies
    ) private view returns (bool) {
        for (uint256 i = 0; i < _policies.length; i++) {
            if(policies[_roleContext][_role][_policies[i].context][_policies[i].id] == bytes32("")) {
                return false;
            }
        }
        return true;
    }

    function _hasRoleExpectedPolicyCount(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _expectedCount
    ) private view returns (bool) {
        return _getPolicyCount(_roleContext, _role) == _expectedCount;
    }

    function _getPolicyCount(
        bytes32 _roleContext,
        bytes32 _role
    ) private view returns (uint256) {
        return policyCount[_roleContext][_role];
    }

}
