// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./interfaces/IACL.sol";
import "./interfaces/IACLConstants.sol";
import "./interfaces/IAccessControl.sol";
import "./lib/Assignments.sol";
import "./lib/Bytes32.sol";
 
contract ACL is IACL, IACLConstants {
    using Assignments for Assignments.Context;
    using Bytes32 for Bytes32.Set;

    mapping(bytes32 => Assignments.Context) private assignments;
    mapping(bytes32 => Bytes32.Set) private assigners;
    mapping(bytes32 => Bytes32.Set) private roleToGroups;
    mapping(bytes32 => Bytes32.Set) private groupToRoles;
    mapping(bytes32 => Bytes32.Set) private subjectContexts;

    mapping(uint256 => bytes32) public contexts;
    mapping(bytes32 => bool) public isContext;
    uint256 public numContexts;

    bytes32 public adminRole;
    bytes32 public adminRoleGroup;
    bytes32 public systemContext;

    modifier assertIsAdmin() {
        require(isAdmin(msg.sender), "unauthorized - must be admin");
        _;
    }

    modifier assertIsAssigner(
        bytes32 _context,
        bytes32 _did,
        bytes32 _role
    ) {
        uint256 ca = canAssign(_context, msg.sender, _did, _role);
        require(ca != CANNOT_ASSIGN && ca != CANNOT_ASSIGN_USER_NOT_APPROVED, "unauthorized");
        _;
    }

    modifier assertIsRoleGroup(bytes32 _roleGroup) {
        require(isRoleGroup(_roleGroup), "must be role group");
        _;
    }

    constructor(bytes32 _adminRole, bytes32 _adminRoleGroup) {
        adminRole = _adminRole;
        adminRoleGroup = _adminRoleGroup;
        systemContext = keccak256(abi.encodePacked(address(this)));

        // setup admin rolegroup
        bytes32[] memory roles = new bytes32[](1);
        roles[0] = _adminRole;
        _setRoleGroup(adminRoleGroup, roles);

        // set creator as admin
        _assignRole(systemContext, msg.sender, _adminRole);
    }

    // Admins

    function isAdmin(bytes32 _did) public view override returns (bool) {
        return hasRoleInGroup(systemContext, _did, adminRoleGroup);
    }

    function addAdmin(bytes32 _did) public override {
        assignRole(systemContext, _did, adminRole);
    }

    function removeAdmin(bytes32 _did) public override {
        unassignRole(systemContext, _did, adminRole);
    }

    // Contexts

    function getNumContexts() public view override returns (uint256) {
        return numContexts;
    }

    function getContextAtIndex(uint256 _index) public view override returns (bytes32) {
        return contexts[_index];
    }

    function getNumSubjectsInContext(bytes32 _context) public view override returns (uint256) {
        return assignments[_context].getNumSubjects();
    }

    function getSubjectInContextAtIndex(bytes32 _context, uint256 _index) public view override returns (bytes32) {
        return assignments[_context].getSubjectAtIndex(_index);
    }

    // Subjects

    function getNumContextsForSubject(bytes32 _did) public view override returns (uint256) {
        return subjectContexts[_did].size();
    }

    function getContextForSubjectAtIndex(bytes32 _did, uint256 _index) public view override returns (bytes32) {
        return subjectContexts[_did].get(_index);
    }

    function subjectSomeHasRoleInContext(bytes32 _context, bytes32 _did) public view override returns (bool) {
        return subjectContexts[_did].has(_context);
    }

    // Role groups

    function hasRoleInGroup(
        bytes32 _context,
        bytes32 _did,
        bytes32 _roleGroup
    ) public view override returns (bool) {
        return hasAnyRole(_context, _did, groupToRoles[_roleGroup].getAll());
    }

    function setRoleGroup(bytes32 _roleGroup, bytes32[] memory _roles) public override assertIsAdmin {
        _setRoleGroup(_roleGroup, _roles);
    }

    function getRoleGroup(bytes32 _roleGroup) public view override returns (bytes32[] memory) {
        return groupToRoles[_roleGroup].getAll();
    }

    function isRoleGroup(bytes32 _roleGroup) public view override returns (bool) {
        return getRoleGroup(_roleGroup).length > 0;
    }

    function getRoleGroupsForRole(bytes32 _role) public view override returns (bytes32[] memory) {
        return roleToGroups[_role].getAll();
    }

    // Roles

    function hasRole(
        bytes32 _context,
        bytes32 _did,
        bytes32 _role
    ) public view override returns (uint256) {
        if (assignments[_context].hasRoleForSubject(_role, _did)) {
            return HAS_ROLE_CONTEXT;
        } else if (assignments[systemContext].hasRoleForSubject(_role, _did)) {
            return HAS_ROLE_SYSTEM_CONTEXT;
        } else {
            return DOES_NOT_HAVE_ROLE;
        }
    }

    function hasAnyRole(
        bytes32 _context,
        bytes32 _did,
        bytes32[] memory _roles
    ) public view override returns (bool) {
        bool hasAny = false;

        for (uint256 i = 0; i < _roles.length; i++) {
            if (hasRole(_context, _did, _roles[i]) != DOES_NOT_HAVE_ROLE) {
                hasAny = true;
                break;
            }
        }

        return hasAny;
    }

    /**
     * @dev assign a role to a did
     */
    function assignRole(
        bytes32 _context,
        bytes32 _did,
        bytes32 _role
    ) public override assertIsAssigner(_context, _did, _role) {
        _assignRole(_context, _did, _role);
    }

    /**
     * @dev remove a role from a did
     */
    function unassignRole(
        bytes32 _context,
        bytes32 _did,
        bytes32 _role
    ) public override assertIsAssigner(_context, _did, _role) {
        if (assignments[_context].hasRoleForSubject(_role, _did)) {
            assignments[_context].removeRoleForSubject(_role, _did);
        }

        // update subject's context list?
        if (!assignments[_context].hasSubject(_did)) {
            subjectContexts[_did].remove(_context);
        }

        emit RoleUnassigned(_context, _did, _role);
    }

    function getRolesForSubject(bytes32 _context, bytes32 _did) public view override returns (bytes32[] memory) {
        return assignments[_context].getRolesForSubject(_did);
    }

    function getSubjectsForRole(bytes32 _context, bytes32 _role) public view override returns (bytes32[] memory) {
        return assignments[_context].getSubjectsForRole(_role);
    }

    // Role assigners

    function addAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup) public override assertIsAdmin assertIsRoleGroup(_assignerRoleGroup) {
        assigners[_roleToAssign].add(_assignerRoleGroup);
        emit AssignerAdded(_roleToAssign, _assignerRoleGroup);
    }

    function removeAssigner(bytes32 _roleToAssign, bytes32 _assignerRoleGroup) public override assertIsAdmin assertIsRoleGroup(_assignerRoleGroup) {
        assigners[_roleToAssign].remove(_assignerRoleGroup);
        emit AssignerRemoved(_roleToAssign, _assignerRoleGroup);
    }

    function getAssigners(bytes32 _role) public view override returns (bytes32[] memory) {
        return assigners[_role].getAll();
    }

    function canAssign(
        bytes32 _context,
        bytes32 _assigner,
        bytes32 _assignee,
        bytes32 _role
    ) public view override returns (uint256) {
        // if they are an admin
        if (isAdmin(_assigner)) {
            return CAN_ASSIGN_IS_ADMIN;
        }

        // if they are assigning within their own context
        if (_context == generateContextFromDID(_assigner)) {
            return CAN_ASSIGN_IS_OWN_CONTEXT;
        }

        // at this point we need to confirm that the assignee is approved
        if (hasRole(systemContext, _assignee, ROLE_APPROVED_USER) == DOES_NOT_HAVE_ROLE) {
            return CANNOT_ASSIGN_USER_NOT_APPROVED;
        }

        // if they belong to a role group that can assign this role
        bytes32[] memory roleGroups = getAssigners(_role);

        for (uint256 i = 0; i < roleGroups.length; i++) {
            bytes32[] memory roles = getRoleGroup(roleGroups[i]);

            if (hasAnyRole(_context, _assigner, roles)) {
                return CAN_ASSIGN_HAS_ROLE;
            }
        }

        return CANNOT_ASSIGN;
    }

    function generateContextFromDID(bytes32 _did) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(_did));
    }

    // Internal functions

    /**
     * @dev assign a role to a did
     */
    function _assignRole(
        bytes32 _context,
        bytes32 _assignee,
        bytes32 _role
    ) private {
        // record new context if necessary
        if (!isContext[_context]) {
            contexts[numContexts] = _context;
            isContext[_context] = true;
            numContexts++;
        }

        assignments[_context].addRoleForSubject(_role, _assignee);

        // update subject's context list
        subjectContexts[_assignee].add(_context);

        // only admin should be able to assign somebody in the system context
        if (_context == systemContext) {
            require(isAdmin(msg.sender), "only admin can assign role in system context");
        }

        emit RoleAssigned(_context, _assignee, _role);
    }

    function _setRoleGroup(bytes32 _roleGroup, bytes32[] memory _roles) private {
        // remove old roles
        bytes32[] storage oldRoles = groupToRoles[_roleGroup].getAll();

        for (uint256 i = 0; i < oldRoles.length; i += 1) {
            bytes32 r = oldRoles[i];
            roleToGroups[r].remove(_roleGroup);
        }

        groupToRoles[_roleGroup].clear();

        // set new roles
        for (uint256 i = 0; i < _roles.length; i += 1) {
            bytes32 r = _roles[i];
            roleToGroups[r].add(_roleGroup);
            groupToRoles[_roleGroup].add(r);
        }

        emit RoleGroupUpdated(_roleGroup);
    }
}
