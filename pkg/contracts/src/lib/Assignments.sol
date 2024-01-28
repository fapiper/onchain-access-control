// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for managing subjects assigned to a role within a context.
 */
library Assignments {
    struct RoleSubjects {
        mapping(string => uint256) map;
        string[] list;
    }

    struct SubjectRoles {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    struct RolePermissions {
        mapping(string => uint256) map;
        string[] list;
    }

    struct PermissionRoles {
        mapping(bytes32 => uint256) map;
        string[] list;
    }

    struct Context {
        mapping(string => RolePermissions) rolePermissions;
        mapping(bytes32 => PermissionRoles) permissionRoles;
        mapping(bytes32 => RoleSubjects) roleSubjects;
        mapping(string => SubjectRoles) subjectRoles;
        mapping(string => uint256) permissionMap;
        string[] permissionList;
        mapping(string => uint256) subjectMap;
        string[] subjectList;
    }

    /**
     * @dev give a did access to a role
     */
    function addRoleForSubject(
        Context storage _context,
        bytes32 _role,
        string memory _did
    ) internal {
        SubjectRoles storage ur = _context.subjectRoles[_did];
        RoleSubjects storage ru = _context.roleSubjects[_role];

        // new subject?
        if (_context.subjectMap[_did] == 0) {
            _context.subjectList.push(_did);
            _context.subjectMap[_did] = _context.subjectList.length;
        }

        // set role for subject
        if (ur.map[_role] == 0) {
            ur.list.push(_role);
            ur.map[_role] = ur.list.length;
        }

        // set subject for role
        if (ru.map[_did] == 0) {
            ru.list.push(_did);
            ru.map[_did] = ru.list.length;
        }
    }

    /**
     * @dev remove a did's access to a role
     */
    function removeRoleForSubject(
        Context storage _context,
        bytes32 _role,
        string memory _did
    ) internal {
        SubjectRoles storage ur = _context.subjectRoles[_did];
        RoleSubjects storage ru = _context.roleSubjects[_role];

        // remove from addr -> role map
        uint256 idx = ur.map[_role];
        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (ur.list.length - 1 > actualIdx) {
                ur.list[actualIdx] = ur.list[ur.list.length - 1];
                ur.map[ur.list[actualIdx]] = actualIdx + 1;
            }

            ur.list.pop();
            ur.map[_role] = 0;
        }

        // remove from role -> addr map
        idx = ru.map[_did];
        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (ru.list.length - 1 > actualIdx) {
                ru.list[actualIdx] = ru.list[ru.list.length - 1];
                ru.map[ru.list[actualIdx]] = actualIdx + 1;
            }

            ru.list.pop();
            ru.map[_did] = 0;
        }

        // remove subject if they don't have roles anymore
        if (ur.list.length == 0) {
            uint256 actualIdx = _context.subjectMap[_did] - 1;

            // replace item to remove with last item in list and update mappings
            if (_context.subjectList.length - 1 > actualIdx) {
                _context.subjectList[actualIdx] = _context.subjectList[_context.subjectList.length - 1];
                _context.subjectMap[_context.subjectList[actualIdx]] = actualIdx + 1;
            }

            _context.subjectList.pop();
            _context.subjectMap[_did] = 0;
        }
    }

    /**
     * @dev give a did access to a role
     */
    function addPermissionForRole(
        Context storage _context,
        bytes32 _id,
        bytes32 _role
    ) internal {
        RolePermissions storage rp = _context.rolePermissions[_role];
        PermissionRoles storage pr = _context.permissionRoles[_id];

        _context.permissionList.push(_id);
        _context.permissionMap[_did] = _context.permissionList.length;

        // set permission for role
        pr.list.push(_role);
        pr.map[_role] = pr.list.length;

        // set role for permission
        rp.list.push(_id);
        rp.map[_id] = rp.list.length;
    }

    /**
     * @dev remove a permissions assignment to a role
     */
    function removePermissionForRole(
        Context storage _context,
        bytes32 _id,
        bytes32 _role
    ) internal {
        RolePermissions storage rp = _context.rolePermissions[_role];
        PermissionRoles storage pr = _context.permissionRoles[_id];

        // remove from role -> permission map
        uint256 idx = rp.map[_role];
        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (rp.list.length - 1 > actualIdx) {
                rp.list[actualIdx] = rp.list[rp.list.length - 1];
                rp.map[rp.list[actualIdx]] = actualIdx + 1;
            }

            rp.list.pop();
            rp.map[_role] = 0;
        }

        // remove from permission -> role map
        idx = pr.map[_id];
        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (pr.list.length - 1 > actualIdx) {
                pr.list[actualIdx] = pr.list[pr.list.length - 1];
                pr.map[pr.list[actualIdx]] = actualIdx + 1;
            }

            pr.list.pop();
            pr.map[_id] = 0;
        }
    }

    /**
     * @dev check if a did has a role
     * @return bool
     */
    function hasRoleForSubject(
        Context storage _context,
        bytes32 _role,
        string memory _did
    ) internal view returns (bool) {
        SubjectRoles storage ur = _context.subjectRoles[_did];

        return (ur.map[_role] > 0);
    }

    /**
     * @dev check if a role has a permission
     * @return bool
     */
    function hasPermissionForRole(
        Context storage _context,
        bytes32 _role,
        bytes32 _id
    ) internal view returns (bool) {
        PermissionRoles storage pr = _context.permissionRoles[_id];

        return (pr.map[_role] > 0);
    }

    /**
     * @dev get all roles for did
     * @return bytes32[]
     */
    function getRolesForSubject(Context storage _context, string memory _did) internal view returns (bytes32[] storage) {
        SubjectRoles storage ur = _context.subjectRoles[_did];

        return ur.list;
    }

    /**
     * @dev get all permissions for a role
     * @return bytes32[]
     */
    function getPermissionsForRole(Context storage _context, bytes32 _role) internal view returns (bytes32[] storage) {
        RolePermissions storage rp = _context.rolePermissions[_role];

        return rp.list;
    }

    /**
     * @dev get all dids assigned the given role
     * @return string[]
     */
    function getSubjectsForRole(Context storage _context, bytes32 _role) internal view returns (string[] storage) {
        RoleSubjects storage ru = _context.roleSubjects[_role];

        return ru.list;
    }

    /**
     * @dev get all roles mapped to a permission
     * @return string[]
     */
    function getRolesForPermission(Context storage _context, bytes32 _permission) internal view returns (string[] storage) {
        PermissionRoles storage pr = _context.permissionRoles[_permission];

        return pr.list;
    }

    /**
     * @dev get number of dids with roles
     * @return uint256
     */
    function getNumSubjects(Context storage _context) internal view returns (uint256) {
        return _context.subjectList.length;
    }

    /**
     * @dev get dids at given index in list of dids
     * @return string
     */
    function getSubjectAtIndex(Context storage _context, uint256 _index) internal view returns (string storage) {
        return _context.subjectList[_index];
    }

    /**
     * @dev get whether given dids have a role in this context
     * @return bool
     */
    function hasSubject(Context storage _context, string memory _did) internal view returns (bool) {
        return _context.subjectMap[_did] != 0;
    }

}
