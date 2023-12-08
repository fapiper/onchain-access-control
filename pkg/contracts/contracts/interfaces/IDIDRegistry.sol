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
 
    function addController(string memory identity, address controller) external;
    function getController(string memory identity) external view returns (address);
    function removeController(string memory identity, address controller) external;
    function changeController(string memory identity, address newController) external;
    function isController(string memory identity, address actor) external view returns (bool);
}
