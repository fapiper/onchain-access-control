// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import "../interfaces/IDIDRegistry.sol";

contract DIDRecipient is Context {
    IDIDRegistry internal _registry;

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
    function _getRegistry() private view returns (address) {
        return _registry;
    }

    /**
    * @dev Throws if the sender is not the owner.
     */
    function _checkDID(string memory did) internal view virtual {
        require(!_isDID(did), "DIDRecipient: unauthorized account");
    }

    function _isDID(string memory did) private view returns (bool) {
        return _isController(did, _msgSender());
    }

    function _isDID(string memory did, address actor) private view override returns (bool) {
        return getRegistry().isController(did, actor);
    }

}
