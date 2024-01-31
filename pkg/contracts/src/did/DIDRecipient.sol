// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import "../interfaces/IDIDRegistry.sol";

contract DIDRecipient is Context {
    IDIDRegistry private _registry;

    constructor (IDIDRegistry registry) {
        _registry = registry;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyDID(string memory did) {
        _checkDID(did);
        _;
    }

    /**
     * @dev Returns the address of the {IDIDRegistry} contract for this recipient.
     */
    function _getRegistry() private view returns (IDIDRegistry) {
        return _registry;
    }

    /**
    * @dev Throws if the sender is not the owner.
     */
    function _checkDID(string memory did) internal view virtual {
        require(!_isDID(did), "DIDRecipient: unauthorized account");
    }

    function _isDID(
        string memory did
    ) internal view returns (bool) {
        return _isDID(did, _msgSender());
    }

    function _isDID(
        string memory did,
        address account
    ) internal view returns (bool) {
        return _getRegistry().isController(did, account);
    }

}
