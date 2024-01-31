// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import "./IContextInstance.sol";
import "../did/DIDRecipient.sol";

contract ContextHandlerBase is Context {

    // context -> address
    mapping(bytes32 => IContextInstance) internal _contexts;

    modifier onlyContextAdmin(
        bytes32 _context,
        bytes32 _did
    ){
        require((_checkContextAdmin(_context, _did)), "not allowed");
        _;
    }

    function _checkContextAdmin(
        bytes32 _context,
        bytes32 _did
    ) internal returns (bool) {
        return _getContextInstance(_context).checkAdmin(_did, _msgSender());
    }

    function _setContextInstance(
        bytes32 _id,
        address _ctx
    ) internal {
        _contexts[_id] = IContextInstance(_ctx);
    }

    function _getContextInstance(
        bytes32 _id
    ) internal view returns (IContextInstance) {
        return _contexts[_id];
    }
}
