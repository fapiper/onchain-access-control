// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./lib/Groups.sol";
import "./did/DIDRecipient.sol";

contract ContextHandler is DIDRecipient {
    using Groups for Groups.Map;

    // context -> address
    mapping(bytes32 => address) private contexts;

    function verifyAndGrantRole(bytes32 _context, bytes32 _role) external {
        // verify policy
        // grant role
    }

    function grantRole(bytes32 _context, bytes32 _role) external {
        // verify policy
        // assign role
    }

    function revokeRole(bytes32 _context, bytes32 _role) external {
        // verify policy
        // assign role
    }

    function createAccessContext(bytes32 _id) external {
        // TODO deploy access context
        IAccessContext _context = IAccessContext("");
        _setAccessContext(_id, _context);
    }

    function updateAccessContext(bytes32 _id, IAccessContext _context) external {
        _setAccessContext(_id, _context);
    }

    function deleteAccessContext(bytes32 _id) external {
        delete contexts[_id];
    }

    function getAccessContext(bytes32 _id) external view returns (IAccessContext) {
        return _getAccessContext(_id);
    }

    function _setAccessContext(bytes32 _id, IAccessContext _context) internal {
        contexts[_id] = _context;
    }

    function _getAccessContext(bytes32 _id) internal view returns (IAccessContext) {
        return contexts[_id];
    }
}
