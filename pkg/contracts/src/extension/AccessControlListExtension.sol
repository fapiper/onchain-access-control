// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

contract AccessControlListExtension {
 
    // role context -> roles -> count policies
    mapping(bytes32 => mapping(bytes32 => uint256)) internal policyCount;
    // role context -> roles -> policy context -> policies
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bytes32))) internal policies;
    // role context -> roles -> permissions
    mapping(bytes32 => mapping(bytes32 => bytes32)) internal permissions;

    function _assignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissions
    ) internal {
        for (uint256 i = 0; i < _permissions.length; i++) {
            _assignPermissionToRole(_roleContext, _role, _permissions[i]);
        }
    }

    function _assignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permission
    ) internal {
        permissions[_roleContext][_role] = _permission;
    }

    function _unassignPermissionsToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _permissions
    ) internal {
        for (uint256 i = 0; i < _permissions.length; i++) {
            _unassignPermissionToRole(_roleContext, _role, _permissions[i]);
        }
    }

    function _unassignPermissionToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _permission
    ) internal {
        delete permissions[_roleContext][_role][_permission];
    }

    function _assignPoliciesToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies
    ) internal {
        for (uint256 i = 0; i < _policyContexts.length; i++) {
            _assignPolicyToRole(_roleContext, _role, _policyContexts[i], _policies[i]);
        }
    }

    function _assignPolicyToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy
    ) internal {
        policies[_roleContext][_role][_policyContext] = _policy;
        policyCount[_roleContext][_role] += 1;
    }

    function _unassignPoliciesToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies
    ) internal {
        for (uint256 i = 0; i < _policyContexts.length; i++) {
            _unassignPolicyToRole(_roleContext, _role, _policyContexts[i], _policies[i]);
        }
    }

    function _unassignPolicyToRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        bytes32 _policy
    ) internal {
        require(_getPolicyCount(_roleContext, _role) > 0, "no policy found for role");
        delete policies[_role][_policyContext][_policy];
        policyCount[_roleContext][_role] -= 1;
    }

    function _hasRolePolicies(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32[] memory _policyContexts,
        uint256[] memory _policies
    ) internal view returns (bool) {
        for (uint256 i = 0; i < _policies.length; i++) {
            if(!_hasRolePolicy(_roleContext, _role, _policyContexts[i], _policies[i])){
                return false;
            }
        }
        return true;
    }

    function _hasRolePolicy(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _policyContext,
        uint256 _policy
    ) internal view returns (bool) {
        return policies[_roleContext][_role][_policyContext][_policy] == bytes32("");
    }

    function _hasRoleExpectedPolicyCount(
        bytes32 _roleContext,
        bytes32 _role,
        uint256 _expectedCount
    ) internal view returns (bool) {
        return _getPolicyCount(_roleContext, _role) == _expectedCount;
    }

    function _getPolicyCount(
        bytes32 _roleContext,
        bytes32 _role
    ) internal view returns (uint256) {
        return policyCount[_roleContext][_role];
    }

}
