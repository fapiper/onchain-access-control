// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IContextHandler.sol";
import "./ContextHandlerRecipient.sol";

contract ContextInstance is ContextHandlerRecipient {
 
    bytes32 private _contextId;

    constructor(
        bytes32 contextId,
        address contextHandler
    ) ContextHandlerRecipient(contextHandler) {
        _contextId = contextId;
    }

    function _thisContext() internal view returns (bytes32) {
        return _context(_contextId);
    }

    function _thisContextInstance() internal view returns (IContextInstance) {
        return _contextInstance(_contextId);
    }
}
