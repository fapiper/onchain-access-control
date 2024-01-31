// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import "./ISessionRegistry.sol";

contract SessionRecipient is Context {
    ISessionRegistry private sessionRegistry_;

    constructor (ISessionRegistry sessionRegistry) {
        _setSessionRegistry(sessionRegistry);
    }

    modifier onlySessionRegistry() {
        _checkSessionRegistry();
        _;
    }

    function _getSessionRegistry() internal view returns (ISessionRegistry) {
        return sessionRegistry_;
    }

    function _setSessionRegistry(
        ISessionRegistry _sessionRegistry
    ) internal {
        sessionRegistry_ = _sessionRegistry;
    }

    function _checkSessionRegistry() internal view {
        require(_getSessionRegistry() == _msgSender(), "SessionRecipient: unauthorized account");
    }
}
