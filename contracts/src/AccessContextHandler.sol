// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./context/IContextHandler.sol";
import "./context/ContextHandlerBase.sol";
import "./session/SessionRecipient.sol";

contract AccessContextHandler is IContextHandler, SessionRecipient, ContextHandlerBase {
 
    constructor() SessionRecipient(address(0)) {}
 
    function createContextInstance(
        bytes32 _id,
        bytes32 _did
    ) onlyContextAdmin(_id, _did) external {
        // TODO deploy access context
        address _ctx = address(0);
        _setContextInstance(_id, _ctx);
    }

    function setSessionRegistry(
        address sessionRegistry
    ) external {
        _setSessionRegistry(sessionRegistry);
    }

    function startSession(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _did,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies,
        bytes[] memory _args,
        bytes32 _tokenId,
        bytes32 _token
    ) external {
        _getContextInstance(_roleContext).grantRole(_role, _did, _policyContexts, _policies, _args);
        _getSessionRegistry().startSession(_tokenId, _token, _did);
    }

    function deleteContextInstance(
        bytes32 _id,
        bytes32 _did
    ) onlyContextAdmin(_id, _did) external {
        _setContextInstance(_id, address(0));
    }

    function getContextInstance(bytes32 _id) external view returns (IContextInstance) {
        return _getContextInstance(_id);
    }
}
