// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IACL {
    // admin
    function isAdmin(string memory _did, address _addr) external returns (bool);

    function addAdmin(string memory _assigner, string memory _assignee) external;

    function removeAdmin(string memory _assigner, string memory _assignee) external;

    // contexts
    function getNumContexts() external view returns (uint256);

    function getContextAtIndex(uint256 _index) external view returns (bytes32);

    function getNumSubjectsInContext(bytes32 _context) external view returns (uint256);

    function getSubjectInContextAtIndex(bytes32 _context, uint _index) external view returns (string memory);

    // subjects
    function getNumContextsForSubject(string memory _did) external view returns (uint256);

    function getContextForSubjectAtIndex(string memory _did, uint256 _index) external view returns (bytes32);

    function subjectSomeHasRoleInContext(bytes32 _context, string memory _did) external view returns (bool);

    // role groups
    function hasRoleInGroup(bytes32 _context, string memory _did, bytes32 _roleGroup) external view returns (bool);

    function setRoleGroup(bytes32 _roleGroup, bytes32[] calldata _roles, string memory _did) external;

    function isRoleGroup(bytes32 _roleGroup) external view returns (bool);

    function getRoleGroup(bytes32 _roleGroup) external view returns (bytes32[] memory);

    function getRoleGroupsForRole(bytes32 _role) external view returns (bytes32[] memory);

    // roles
    function hasRole(bytes32 _context, string memory _did, bytes32 _role) external view returns (uint256);

    function hasAnyRole(bytes32 _context, string memory _did, bytes32[] calldata _roles) external view returns (bool);

    function assignRole(bytes32 _context, string memory _assigner, string memory _assignee, bytes32 _role) external;

    function unassignRole(bytes32 _context, string memory _assigner, string memory _assignee, bytes32 _role) external;

    function getRolesForSubject(bytes32 _context, string memory _did) external view returns (bytes32[] memory);

    // who can assign roles
    function addAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup, string memory _did) external;

    function removeAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup, string memory _did) external;

    function getAssigners(bytes32 _role) external view returns (bytes32[] memory);

    function canAssign(bytes32 _context, string memory _assigner, string memory _assignee, bytes32 _role) external returns (uint256);

    // utility methods
    function generateContextFromDID(string memory _did) external pure returns (bytes32);

    /**
     * @dev Emitted when a role group gets updated.
     * @param roleGroup The rolegroup which got updated.
     */
    event RoleGroupUpdated(bytes32 indexed roleGroup);

    /**
     * @dev Emitted when a role gets assigned.
     * @param context The context within which the role got assigned.
     * @param did The did the role got assigned to.
     * @param role The role which got assigned.
     */
    event RoleAssigned(bytes32 indexed context, string indexed did, bytes32 indexed role);

    /**
     * @dev Emitted when a role gets unassigned.
     * @param context The context within which the role got assigned.
     * @param did The did the role got assigned to.
     * @param role The role which got unassigned.
     */
    event RoleUnassigned(bytes32 indexed context, string indexed did, bytes32 indexed role);

    /**
     * @dev Emitted when a role assigner gets added.
     * @param role The role that can be assigned.
     * @param roleGroup The rolegroup that will be able to assign this role.
     */
    event AssignerAdded(bytes32 indexed role, bytes32 indexed roleGroup);

    /**
     * @dev Emitted when a role assigner gets removed.
     * @param role The role that can be assigned.
     * @param roleGroup The rolegroup that will no longer be able to assign this role.
     */
    event AssignerRemoved(bytes32 indexed role, bytes32 indexed roleGroup);

}
