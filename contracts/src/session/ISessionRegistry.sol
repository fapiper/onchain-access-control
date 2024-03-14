// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ISessionRegistry {
    function setContextHandler(address _contextHandler) external;
    function startSession(bytes32 _id, bytes memory _token, bytes32 _did) external;
    function revokeSession(bytes32 _id) external;
    function isSessionValid(bytes32 _id) external returns (bool);
}
