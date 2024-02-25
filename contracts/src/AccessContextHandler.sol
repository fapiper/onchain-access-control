// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./context/IContextHandler.sol";
import "./context/ContextHandlerBase.sol";
import "./session/SessionRecipient.sol";

contract AccessContextHandler is IContextHandler, SessionRecipient, ContextHandlerBase {
 
    constructor(
        address instanceImpl,
        address didRegistry
    ) ContextHandlerBase(instanceImpl, didRegistry) SessionRecipient(address(0)) {}
 
    function createContextInstance(
        bytes32 _id,
        bytes20 _salt,
        bytes32 _did
    ) onlyContextAdmin(_id, _did) external {
        address payable _instance = _createContextInstance(_salt, _did, _id);
        _setContextInstance(_id, _instance);
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
        _forwardGrantRole(_roleContext, _role, _did, _policyContexts, _policies, _args);
        _forwardStartSession(_tokenId, _token, _did);
    }

    function startSession(
        bytes32 _did,
        bytes32 _tokenId,
        bytes32 _token
    ) external {
        _forwardStartSession(_tokenId, _token, _did);
    }

    function grantRole(
        bytes32 _roleContext,
        bytes32 _role,
        bytes32 _did,
        bytes32[] memory _policyContexts,
        bytes32[] memory _policies,
        bytes[] memory _args
    ) external {
        _forwardGrantRole(_roleContext, _role, _did, _policyContexts, _policies, _args);
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
