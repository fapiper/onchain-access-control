// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "./ContextInstance.sol";
import "../extension/IPolicyExtension.sol";

interface IContextInstance is IPolicyExtension {

    function checkAdmin(string memory _did, address _account) external view returns (bool);
    function getPolicy(bytes32 _context, bytes32 _id) external view returns (Policy memory policy);
}
