// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IContextHandler.sol";
import "./ContextHandlerRecipient.sol";

contract ContextInstance is IPolicyExtension, ContextHandlerRecipient {
 
    bytes32 private _contextId;

    constructor(
        bytes32 contextId,
        IContextHandler contextHandler
    ) ContextHandlerRecipient(contextHandler) {
        _contextId = contextId;
    }

    function _getPolicy(
        bytes32 context_,
        bytes32 policy_
    ) internal view returns (Policy memory) {
        return _context(context_).getPolicy(context_, policy_);
    }

    function _thisContext() internal view returns (IContextInstance) {
        return _context(_contextId);
    }
}
