// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Policies {

    struct Policy {
        bytes32 context;
        bytes32 id;
        address instance;
        bytes4 verify;
        bool exists;
    }

    // context -> id -> policies
    mapping(bytes32 => mapping(bytes32 => Policy)) internal policies;

    function _registerPolicy(
        bytes32 _context,
        bytes32 _id,
        address _instance,
        bytes4 _verify
    ) private {
        require(!policies[_context][_id].exists, "policy already exists");
        Policy memory policy = Policy(
            _context,
            _id,
            _instance,
            _verify,
            true
        );
        policies[_context][_id] = policy;
    }

    function _unregisterPolicy(
        bytes32 _context,
        bytes32 _id
    ) private {
        delete policies[_context][_id];
    }

    function _getPolicy(
        bytes32 _context,
        bytes32 _id
    ) private returns (Policy memory) {
        return policies[_context][_id];
    }

    function _verifyPolicy(
        Policy memory _policy,
        bytes memory _args
    ) private returns (bool) {
        (bool success, bytes memory result) = _policy.instance.delegatecall(
            abi.encodeWithSelector(
                _policy.verify,
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
        Policy[] memory _policies,
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
