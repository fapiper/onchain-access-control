// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./interfaces/IPolicyRegistry.sol";

contract PolicyRegistry is IPolicyRegistry {

    mapping(bytes32 => Policy) private policies;

    modifier policyExists(bytes32 _id) {
        require(policies[_id].exists, 'policy not found');
        _;
    }

    modifier onlyController(bytes32 _id) {
        require(isController(_id, msg.sender), 'Not authorized');
        _;
    }

    function isController(bytes32 _id, address _addr) public view returns (bool) {
        return policies[_id].controller == _addr;
    }

    function addPolicy(bytes32 _id, address _controller, address _verifierContract, bytes4 _verifyMethodId) external {
        require(!policies[_id].exists, "policy id already exists");
        Policy memory policy = Policy(_id, _controller, _verifierContract, _verifyMethodId, block.timestamp, true);
        policies[_id] = policy;
        emit PolicyRegistered(policy);
    }

    function getPolicy(bytes32 _id) policyExists(_id) public view returns (Policy memory){
        return policies[_id];
    }

    function removePolicy(bytes32 _id) policyExists(_id) onlyController(_id) external {
        delete policies[_id];
    }

    function verifyPolicy(bytes32 _id, bytes memory _args) policyExists(_id) public returns (bool) {
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
        bool isVerified = abi.decode(result, (bool));
        emit PolicyVerified(policy.id, isVerified);
        return isVerified;
    }
}