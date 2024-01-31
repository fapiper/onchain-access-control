// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IContextHandler.sol";

contract ContextHandlerRecipient {

    IContextHandler private contextHandler_;

    constructor(
        IContextHandler contextHandler
    ) {
        _setContextHandler(contextHandler);
    }

    function _setContextHandler(IContextHandler contextHandler) internal {
        contextHandler_ = contextHandler;
    }

    function _checkContextHandler() internal view returns (bool) {
        return _checkContextHandler(msg.sender);
    }

    function _checkContextHandler(address account) internal view returns (bool) {
        return address(_contextHandler()) == account;
    }

    function _contextHandler() internal view returns (IContextHandler) {
        return contextHandler_;
    }

    function _context(bytes32 context) internal view returns (IContextInstance) {
        return _contextHandler().getContextInstance(context);
    }
}
