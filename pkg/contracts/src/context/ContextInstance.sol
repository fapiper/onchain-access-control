// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IContextHandler.sol";
import "./ContextHandlerRecipient.sol";

contract ContextInstance is ContextHandlerRecipient {
 
    bytes32 private _contextId;

    constructor(
        bytes32 contextId,
        IContextHandler contextHandler
    ) ContextHandlerRecipient(contextHandler) {
        _contextId = contextId;
    }

    function _thisContext() internal view returns (IContextInstance) {
        return _context(_contextId);
    }
}
