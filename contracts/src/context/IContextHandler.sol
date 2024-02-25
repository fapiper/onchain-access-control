// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "./IContextInstance.sol";

interface IContextHandler {
    function createContextInstance(bytes32 _id, bytes20 _salt, bytes32 _did) external;
    function deleteContextInstance(bytes32 _id, bytes32 _did) external;
    function getContextInstance(bytes32 _id) external view returns (IContextInstance);
}
