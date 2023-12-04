// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IACL {
  // admin
  function isAdmin(bytes32 _did) external view returns (bool);
  function addAdmin(bytes32 _did) external;
  function removeAdmin(bytes32 _did) external;
    
  // contexts
  function getNumContexts() external view returns (uint256);
  function getContextAtIndex(uint256 _index) external view returns (bytes32);
  function getNumSubjectsInContext(bytes32 _context) external view returns (uint256);
  function getSubjectInContextAtIndex(bytes32 _context, uint _index) external view returns (bytes32);
    
  // subjects
  function getNumContextsForSubject(bytes32 _did) external view returns (uint256);
  function getContextForSubjectAtIndex(bytes32 _did, uint256 _index) external view returns (bytes32);
  function subjectSomeHasRoleInContext(bytes32 _context, bytes32 _did) external view returns (bool);
    
  // role groups
  function hasRoleInGroup(bytes32 _context, bytes32 _did, bytes32 _roleGroup) external view returns (bool);
  function setRoleGroup(bytes32 _roleGroup, bytes32[] calldata _roles) external;
  function isRoleGroup(bytes32 _roleGroup) external view returns (bool);
  function getRoleGroup(bytes32 _roleGroup) external view returns (bytes32[] memory);
  function getRoleGroupsForRole(bytes32 _role) external view returns (bytes32[] memory);
  
    // roles
  function hasRole(bytes32 _context, bytes32 _did, bytes32 _role) external view returns (bool);
  function hasAnyRole(bytes32 _context, bytes32 _did, bytes32[] calldata _roles) external view returns (bool);
  function assignRole(bytes32 _context, bytes32 _did, bytes32 _role) external;
  function unassignRole(bytes32 _context, bytes32 _did, bytes32 _role) external;
  function getRolesForSubject(bytes32 _context, bytes32 _did) external view returns (bytes32[] memory);
    
  // who can assign roles
  function addAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup) external;
  function removeAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup) external;
  function getAssigners(bytes32 _role) external view returns (bytes32[] memory);
  function canAssign(bytes32 _context, bytes32 _did, bytes32 _role) external view returns (bool);
    
  // utility methods
  function generateContextFromDID (bytes32 _did) external pure returns (bytes32);
}
