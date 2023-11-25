// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for managing users assigned to a role within a context.
 */
library Assignments {
    struct RoleUsers {
        mapping(address => uint256) map;
        address[] list;
    }

    struct UserRoles {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    struct Context {
        mapping(bytes32 => RoleUsers) roleUsers;
        mapping(address => UserRoles) userRoles;
        mapping(address => uint256) userMap;
        address[] userList;
    }

    /**
     * @dev give an address access to a role
     */
    function addRoleForUser(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal {
        UserRoles storage ur = _context.userRoles[_addr];
        RoleUsers storage ru = _context.roleUsers[_role];

        // new user?
        if (_context.userMap[_addr] == 0) {
            _context.userList.push(_addr);
            _context.userMap[_addr] = _context.userList.length;
        }

        // set role for user
        if (ur.map[_role] == 0) {
            ur.list.push(_role);
            ur.map[_role] = ur.list.length;
        }

        // set user for role
        if (ru.map[_addr] == 0) {
            ru.list.push(_addr);
            ru.map[_addr] = ru.list.length;
        }
    }

    /**
     * @dev remove an address' access to a role
     */
    function removeRoleForUser(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal {
        UserRoles storage ur = _context.userRoles[_addr];
        RoleUsers storage ru = _context.roleUsers[_role];

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

        // remove user if they don't have roles anymore
        if (ur.list.length == 0) {
            uint256 actualIdx = _context.userMap[_addr] - 1;

            // replace item to remove with last item in list and update mappings
            if (_context.userList.length - 1 > actualIdx) {
                _context.userList[actualIdx] = _context.userList[_context.userList.length - 1];
                _context.userMap[_context.userList[actualIdx]] = actualIdx + 1;
            }

            _context.userList.pop();
            _context.userMap[_addr] = 0;
        }
    }

    /**
     * @dev check if an address has a role
     * @return bool
     */
    function hasRoleForUser(
        Context storage _context,
        bytes32 _role,
        address _addr
    ) internal view returns (bool) {
        UserRoles storage ur = _context.userRoles[_addr];

        return (ur.map[_role] > 0);
    }

    /**
     * @dev get all roles for address
     * @return bytes32[]
     */
    function getRolesForUser(Context storage _context, address _addr) internal view returns (bytes32[] storage) {
        UserRoles storage ur = _context.userRoles[_addr];

        return ur.list;
    }

    /**
     * @dev get all addresses assigned the given role
     * @return address[]
     */
    function getUsersForRole(Context storage _context, bytes32 _role) internal view returns (address[] storage) {
        RoleUsers storage ru = _context.roleUsers[_role];

        return ru.list;
    }

    /**
     * @dev get number of addresses with roles
     * @return uint256
     */
    function getNumUsers(Context storage _context) internal view returns (uint256) {
        return _context.userList.length;
    }

    /**
     * @dev get addresses at given index in list of addresses
     * @return uint256
     */
    function getUserAtIndex(Context storage _context, uint256 _index) internal view returns (address) {
        return _context.userList[_index];
    }

    /**
     * @dev get whether given addresses has a role in this context
     * @return uint256
     */
    function hasUser(Context storage _context, address _addr) internal view returns (bool) {
        return _context.userMap[_addr] != 0;
    }
}
