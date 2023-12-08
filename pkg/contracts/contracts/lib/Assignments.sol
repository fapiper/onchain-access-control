// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for managing subjects assigned to a role within a context.
 */
library Assignments {
    struct RoleSubjects {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    struct SubjectRoles {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    struct Context {
        mapping(bytes32 => RoleSubjects) roleSubjects;
        mapping(bytes32 => SubjectRoles) subjectRoles;
        mapping(bytes32 => uint256) subjectMap;
        bytes32[] subjectList;
    }

    /**
     * @dev give a did access to a role
     */
    function addRoleForSubject(
        Context storage _context,
        bytes32 _role,
        bytes32 _did
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
        bytes32 _did
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
     * @dev check if a did has a role
     * @return bool
     */
    function hasRoleForSubject(
        Context storage _context,
        bytes32 _role,
        bytes32 _did
    ) internal view returns (bool) {
        SubjectRoles storage ur = _context.subjectRoles[_did];

        return (ur.map[_role] > 0);
    }

    /**
     * @dev get all roles for did
     * @return bytes32[]
     */
    function getRolesForSubject(Context storage _context, bytes32 _did) internal view returns (bytes32[] storage) {
        SubjectRoles storage ur = _context.subjectRoles[_did];

        return ur.list;
    }

    /**
     * @dev get all dids assigned the given role
     * @return bytes32[]
     */
    function getSubjectsForRole(Context storage _context, bytes32 _role) internal view returns (bytes32[] storage) {
        RoleSubjects storage ru = _context.roleSubjects[_role];

        return ru.list;
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
     * @return bytes32
     */
    function getSubjectAtIndex(Context storage _context, uint256 _index) internal view returns (bytes32) {
        return _context.subjectList[_index];
    }

    /**
     * @dev get whether given dids have a role in this context
     * @return bool
     */
    function hasSubject(Context storage _context, bytes32 _did) internal view returns (bool) {
        return _context.subjectMap[_did] != 0;
    }

}
