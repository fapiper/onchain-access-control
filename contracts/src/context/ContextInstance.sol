// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IContextHandler.sol";
import "./ContextHandlerRecipient.sol";

contract ContextInstance is ContextHandlerRecipient {
 
    bytes32 private _contextId;

    function _initContextInstance(
        bytes32 contextId,
        address contextHandler
    ) internal {
        _contextId = contextId;
        _initContextHandlerRecipient(contextHandler);
    }

    function _thisContext() internal view returns (bytes32) {
        return _contextId;
    }

    function _thisContextInstance() internal view returns (IContextInstance) {
        return _contextInstance(_contextId);
    }
}
