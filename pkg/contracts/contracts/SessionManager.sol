// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./interfaces/ISessionManager.sol";

contract SessionManager is ISessionManager {

    mapping(bytes => SessionInfo) private sessions;

    uint256 public maxDuration;

    constructor(uint256 _maxDuration) {
        maxDuration = _maxDuration;
    }

    modifier onlyValidSession(bytes memory _token) {
        require(
            isSessionValid(_token),
            "Invalid session"
        );
        _;
    }

    function setSession(bytes32 memory _token, bytes32 memory _subject, uint256 _duration) external returns (SessionInfo memory) {
        require(_duration <= maxDuration, "Invalid duration");

        SessionInfo memory session = SessionInfo({
            token: _token,
            subject: _subject,
            exists: true,
            expiration: block.timestamp + _duration
        });

        sessions[_token] = session;

        emit NewSession(session);
        return session;
    }

    function revertSession(bytes32 memory _token, bytes32 memory _subject, uint256 _duration) external {
        delete sessions[_token];
    }

    function isSessionValid(bytes memory _token) public view returns (bool) {
        return sessions[_token].expiration >= block.timestamp;
    }

}
