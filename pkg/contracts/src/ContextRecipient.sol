// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./lib/Groups.sol";
import "./did/DIDRecipient.sol";

contract ContextRecipient {

    bytes32 private _contextId;
    IContextHandler private _contextHandler;

    constructor(
        bytes32 contextId,
        address contextHandler
    ) {
        _contextId = contextId;
        _contextHandler = contextHandler;
    }


    function _contextHandler() private view returns (IContextHandler) {
        return _contextHandler;
    }

    function _context(bytes32 _context) private view returns (IAccessContext) {
        return _contextHandler().getAccessContext(_context);
    }

    function _policy(bytes32 _context, bytes32 policy) private view returns (IAccessContext) {
        return _context(_context).getPolicy(policy);
    }

    function _thisContext() private view returns (IAccessContext) {
        return _context(_contextId);
    }
}
