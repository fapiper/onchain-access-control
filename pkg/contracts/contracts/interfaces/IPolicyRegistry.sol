// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IPolicyRegistry {

    event PolicyRegistered(Policy indexed policy);
    event PolicyVerified(bytes policyId, bool indexed result);

    struct Policy {
        bytes id;
        address verifierContract;
        bytes4 verifyMethodId;
        address controller;
        uint256 timestamp;
        bool exists;
    }

    function registerPolicy(bytes memory _policyId, address _policyController, address _verifierContract, bytes4 _verifyMethodId) external;

    function verifyPolicy(bytes memory _policyId, bytes memory _args) external returns (bool);

}