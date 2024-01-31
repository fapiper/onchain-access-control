// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../context/ContextInstance.sol";
import "./IPolicyExtension.sol";

contract PolicyExtension is IPolicyExtension, ContextInstance {

    // context -> id -> policies
    mapping(bytes32 => mapping(bytes32 => Policy)) private policies_;

    constructor(
        address contextId,
        address contextHandler
    ) ContextInstance(contextId, contextHandler) {}

    function _registerPolicy(
        bytes32 _context,
        bytes32 _id,
        address _instance,
        bytes4 _verify
    ) internal {
        require(!policies_[_context][_id].exists, "policy already exists");
        Policy memory policy = Policy(
            _context,
            _id,
            _instance,
            _verify,
            true
        );
        policies_[_context][_id] = policy;
    }

    function _unregisterPolicy(
        bytes32 _context,
        bytes32 _id
    ) internal {
        delete policies_[_context][_id];
    }

    function _getPolicy(
        bytes32 context_,
        bytes32 id_
    ) internal returns (Policy memory) {
        if(context_ == _thisContext()){
            return policies_[context_][id_];
        } else {
            return _context(context_).getPolicy(id_);
        }
    }

    function _getPolicies(
        bytes32[] memory _contexts,
        bytes32[] memory _ids
    ) internal returns (Policy[] memory _policies) {
        uint256 len = _contexts.length;
        _policies = new Policy[](len);
        for (uint256 i = 0; i < len; i++) {
            _policies[i] = _getPolicy(_contexts[i], _ids[i]);
        }
        return _policies;
    }

    function _verifyPolicy(
        Policy memory _policy,
        bytes memory _args
    ) internal returns (bool) {
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
    ) internal returns (bool) {
        for (uint256 i = 0; i < _policies.length; i++) {
            if(!_verifyPolicy(_policies[i], _args[i])) {
                return false;
            }
        }
        return true;
    }
}
