// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IPolicyRegistry {

    event PolicyRegistered(Policy indexed policy);
    event PolicyVerified(bytes32 policyId, bool indexed result);

    struct Policy {
        bytes32 id;
        address controller;
        address policy;
        string document;
        bytes4 verify;
        uint256 timestamp;
        bool exists;
    }

    function isController(bytes32 _id, address _addr) external view returns (bool);
    function addPolicy(bytes32 _id, address _controller, address _verifierContract, bytes4 _verifyMethodId) external;
    function getPolicy(bytes32 _id) external view returns (Policy memory);
    function removePolicy(bytes32 _id) external;
    function verifyPolicy(bytes32 _id, bytes memory _args) external returns (bool);
}
