// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IDIDRegistry {
    struct DIDConfig {
        uint currentController;
    }

    event DIDControllerChanged(
        bytes32 indexed identity,
        address controller
    );

    function addController(bytes32 identity, address controller) external;
    function getController(bytes32 identity) external view returns (address);
    function removeController(bytes32 identity, address controller) external;
    function changeController(bytes32 identity, address newController) external;
    function isController(bytes32 identity, address actor) external view returns (bool);
}
