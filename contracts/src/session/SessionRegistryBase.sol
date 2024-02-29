// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "../context/IContextHandler.sol";
import "../context/ContextHandlerRecipient.sol";
import "../did/DIDRecipient.sol";

contract SessionRegistryBase is DIDRecipient {

    struct SessionInfo {
        bytes32 id;
        bytes32 token;
        bytes32 subject;
        uint256 expiration;
        bool exists;
    }

    mapping(bytes32 => SessionInfo) private _sessions;

    constructor(
        address didRegistry
    ) {
        _initDIDRecipient(didRegistry);
    }

    function _setSession(
        bytes32 _id,
        bytes32 _token,
        bytes32 _subject,
        uint256 duration
    ) internal {
        _sessions[_id] = SessionInfo({
            id: _id,
            token: _token,
            subject: _subject,
            exists: true,
            expiration: block.timestamp + duration
        });
    }

    function _getSession(
        bytes32 _id
    ) internal view returns (SessionInfo memory) {
        return _sessions[_id];
    }

    function _deleteSession(
        bytes32 _id
    ) internal {
        delete _sessions[_id];
    }

    function _checkSessionSubject(
        bytes32 _id
    ) internal returns (bool) {
        return _isDID(_sessions[_id].subject);
    }

    function _checkSessionExists(
        bytes32 _id
    ) internal view returns (bool) {
        return _sessions[_id].exists;
    }

    function _checkSessionValid(
        bytes32 _id
    ) internal view returns (bool) {
        return _sessions[_id].expiration >= block.timestamp;
    }
}
