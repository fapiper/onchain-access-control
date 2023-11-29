// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for managing subjects assigned to a role within a context.
 */
library Assignments {
    struct RoleSubjects {
        mapping(address => uint256) map;
        address[] list;
    }

    struct SubjectRoles {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    struct Context {
        mapping(bytes32 => RoleSubjects) roleSubjects;
        mapping(address => SubjectRoles) subjectRoles;
        mapping(address => uint256) subjectMap;
        address[] subjectList;
    }

    /**
     * @dev give an address access to a role
     */
    function addRoleForSubject(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal {
        SubjectRoles storage ur = _context.subjectRoles[_addr];
        RoleSubjects storage ru = _context.roleSubjects[_role];

        // new subject?
        if (_context.subjectMap[_addr] == 0) {
            _context.subjectList.push(_addr);
            _context.subjectMap[_addr] = _context.subjectList.length;
        }

        // set role for subject
        if (ur.map[_role] == 0) {
            ur.list.push(_role);
            ur.map[_role] = ur.list.length;
        }

        // set subject for role
        if (ru.map[_addr] == 0) {
            ru.list.push(_addr);
            ru.map[_addr] = ru.list.length;
        }
    }

    /**
     * @dev remove an address' access to a role
     */
    function removeRoleForSubject(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal {
        SubjectRoles storage ur = _context.subjectRoles[_addr];
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
        idx = ru.map[_addr];
        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (ru.list.length - 1 > actualIdx) {
                ru.list[actualIdx] = ru.list[ru.list.length - 1];
                ru.map[ru.list[actualIdx]] = actualIdx + 1;
            }

            ru.list.pop();
            ru.map[_addr] = 0;
        }

        // remove subject if they don't have roles anymore
        if (ur.list.length == 0) {
            uint256 actualIdx = _context.subjectMap[_addr] - 1;

            // replace item to remove with last item in list and update mappings
            if (_context.subjectList.length - 1 > actualIdx) {
                _context.subjectList[actualIdx] = _context.subjectList[_context.subjectList.length - 1];
                _context.subjectMap[_context.subjectList[actualIdx]] = actualIdx + 1;
            }

            _context.subjectList.pop();
            _context.subjectMap[_addr] = 0;
        }
    }

    /**
     * @dev check if an address has a role
     * @return bool
     */
    function hasRoleForSubject(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal view returns (bool) {
        SubjectRoles storage ur = _context.subjectRoles[_addr];

        return (ur.map[_role] > 0);
    }

    /**
     * @dev get all roles for address
     * @return bytes32[]
     */
    function getRolesForSubject(Context storage _context, address _addr) internal view returns (bytes32[] storage) {
        SubjectRoles storage ur = _context.subjectRoles[_addr];

        return ur.list;
    }

    /**
     * @dev get all addresses assigned the given role
     * @return address[]
     */
    function getSubjectsForRole(Context storage _context, bytes32 _role) internal view returns (address[] storage) {
        RoleSubjects storage ru = _context.roleSubjects[_role];

        return ru.list;
    }

    /**
     * @dev get number of addresses with roles
     * @return uint256
     */
    function getNumSubjects(Context storage _context) internal view returns (uint256) {
        return _context.subjectList.length;
    }

    /**
     * @dev get addresses at given index in list of addresses
     * @return uint256
     */
    function getSubjectAtIndex(Context storage _context, uint256 _index) internal view returns (address) {
        return _context.subjectList[_index];
    }

    /**
     * @dev get whether given addresses has a role in this context
     * @return uint256
     */
    function hasSubject(Context storage _context, address _addr) internal view returns (bool) {
        return _context.subjectMap[_addr] != 0;
    }
}
