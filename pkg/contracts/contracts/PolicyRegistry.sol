// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./interfaces/IPolicyRegistry.sol";

contract PolicyRegistry is IPolicyRegistry {

    mapping(bytes => Policy) private policies;

    constructor() {}

    function registerPolicy(bytes memory _policyId, address _policyController, address _verifierContract, bytes4 _verifyMethodId) public {
        Policy memory policy = Policy(_policyId, _verifierContract, _verifyMethodId, _policyController, block.timestamp, true);
        require(!policies[_policyId].exists || msg.sender == policy.controller, "Policy id is not allowed");
        policies[_policyId] = policy;
        emit PolicyRegistered(policy);
    }

    function verifyPolicy(bytes memory _policyId, bytes memory _args) public returns (bool) {
        Policy memory policy = policies[_policyId];
        require(policies[_policyId].exists, "Policy not found");
        (bool success, bytes memory result) = policy.verifierContract.delegatecall(
            abi.encodeWithSelector(
                policy.verifyMethodId,
                _args
            )
        );
        if(!success){
            // Just return false instead of a rejection upon delegatecall throwing an error
            return false;
        }
        bool isVerified = abi.decode(result, (bool));
        emit PolicyVerified(policy.id, isVerified);
        return isVerified;
    }
}
