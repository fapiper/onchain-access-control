// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../context/ContextInstance.sol";
import "../policy/IPolicyVerifier.sol";
import "./IPolicyExtension.sol";

contract PolicyExtension is IPolicyExtension, ContextInstance {

    // context -> id -> policies
    mapping(bytes32 => mapping(bytes32 => Policy)) private policies_;

    constructor(
        bytes32 contextId,
        address contextHandler
    ) ContextInstance(contextId, contextHandler) {}

    function _registerPolicy(
        bytes32 _context,
        bytes32 _id,
        address _verifier
    ) internal {
        require(!policies_[_context][_id].exists, "policy already exists");
        Policy memory policy = Policy(
            _context,
            _id,
            IPolicyVerifier(_verifier),
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
    ) internal view returns (Policy memory) {
        if(context_ == _thisContext()){
            return policies_[context_][id_];
        } else {
            return _contextInstance(context_).getPolicy(context_, id_);
        }
    }

    function _getPolicies(
        bytes32[] memory _contexts,
        bytes32[] memory _ids
    ) internal view returns (Policy[] memory _policies) {
        uint256 len = _contexts.length;
        _policies = new Policy[](len);
        for (uint256 i = 0; i < len; i++) {
            _policies[i] = _getPolicy(_contexts[i], _ids[i]);
        }
        return _policies;
    }

    function _verifyPolicy(
        Policy memory _policy,
        IPolicyVerifier.Proof memory _zkVP
    ) internal view returns (bool) {
        return _policy.verifier.verifyTx(_zkVP);
    }

    function _verifyPolicies (
        Policy[] memory _policies,
        IPolicyVerifier.Proof[] memory _zkVPs
    ) internal view returns (bool) {
        for (uint256 i = 0; i < _policies.length; i++) {
            if(!_verifyPolicy(_policies[i], _zkVPs[i])) {
                return false;
            }
        }
        return true;
    }
}
