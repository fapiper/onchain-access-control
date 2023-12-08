// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IDIDRegistry {
    struct DIDConfig {
        uint currentController;
    }

    event DIDControllerChanged(
        string indexed identity,
        address controller
    );

    function addController(string identity, address controller) external;
    function getController(string identity) external view returns (address);
    function removeController(string identity, address controller) external;
    function changeController(string identity, address newController) external;
    function isController(string identity, address actor) external view returns (bool);
}
