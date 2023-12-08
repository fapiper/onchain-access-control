// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface ISessionManager {

    event NewSession (SessionInfo indexed session);
    event RevokeSession (SessionInfo indexed session);

    struct SessionInfo {
        bytes32 token;
        bytes32 subject;
        bool exists;
        uint256 expiration;
    }

    function setSession(bytes32 _token, bytes32 _subject, uint256 _duration) external returns (SessionInfo memory);
    
    function isSessionValid(bytes32 _token) external view returns (bool);
}
