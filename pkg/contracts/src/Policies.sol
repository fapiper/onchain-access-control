// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Policies {

    struct Policy {
        bytes32 id;
        address policy;
        bytes4 verify;
        bool exists;
    }

    // id -> policies
    mapping(bytes32 => Policy) internal policies;

    function _registerPolicy(
        bytes32 _id,
        address _policy,
        bytes4 _verify
    ) private {
        require(!policies[_id].exists, "policy already exists");
        Policy memory policy = Policy(
            _id,
            _policy,
            _verify,
            true
        );
        policies[_id] = policy;
    }

    function _unregisterPolicy(
        bytes32 _id
    ) private {
        delete policies[_id];
    }

    function _verifyPolicy(
        bytes32 _id,
        bytes memory _args
    ) private returns (bool) {
        require(policies[_id].exists, "policy not found");
        Policy memory policy = policies[_id];
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
        return abi.decode(result, (bool));
    }

    function _verifyPolicies (
        bytes32[] memory _policies,
        bytes[] memory _args
    ) private returns (bool) {
        for (uint256 i = 0; i < _policies.length; i++) {
            if(!_verifyPolicy(_policies[i], args[i])) {
                return false;
            }
        }
        return true;
    }
}
