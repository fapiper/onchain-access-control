// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IDIDRegistry {
    struct DIDConfig {
        uint currentController;
    }

    event DIDControllerChanged(
        address indexed identity,
        address controller,
        uint previousChange
    );

    function addController(address identity, address controller) external;
    function getController(address identity, address controller) external view;
    function removeController(address identity, address controller) external;
    function changeController(address identity, address newController) external;
    function isController(bytes32 identity, address actor) external view returns (bool);
}
