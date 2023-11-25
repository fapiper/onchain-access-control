// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface ISessionManager {

    event NewSession (SessionInfo indexed session);
    event RevokeSession (SessionInfo indexed session);

    struct SessionInfo {
        bytes token;
        bool exists;
        uint256 expiration;
    }

    function setSession(bytes memory _token, uint256 _duration) external returns (SessionInfo memory);
    
    function isSessionValid(bytes memory _token) external view returns (bool);
}