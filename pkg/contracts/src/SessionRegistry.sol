// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "./session/SessionRegistryBase.sol";
import "./session/ISessionRegistry.sol";
import "./context/ContextHandlerRecipient.sol";

contract SessionRegistry is ISessionRegistry, SessionRegistryBase, ContextHandlerRecipient {

    constructor(
        address contextHandler,
        address didRegistry
    ) ContextHandlerRecipient(contextHandler) SessionRegistryBase(didRegistry) {}

    modifier onlySubjectOrContextHandler(bytes32 id){
        require(_checkSessionSubject(id) || _checkContextHandler());
        _;
    }

    function setContextHandler(
        address contextHandler
    ) external {
        require(_checkContextHandler(), "not allowed");
        _setContextHandler(contextHandler);
    }

    function startSession(
        bytes32 _id,
        bytes32 _token,
        string memory _subject
    ) override external {
        require(!_checkSessionExists(_id), "session already exists");
        _setSession(_id, _token, _subject, 100);
    }

    function revokeSession(bytes32 _id) onlySubjectOrContextHandler(_id) external {
        require(_checkSessionExists(_id), "session not found");
        _deleteSession(_id);
    }

    function isSessionValid(bytes32 _id) external view returns (bool) {
        return _checkSessionValid(_id);
    }
}
