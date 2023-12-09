// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "./interfaces/IDIDRegistry.sol";

contract SimpleDIDRegistry is IDIDRegistry {

    mapping(string => address[]) public controllers;
    mapping(string => DIDConfig) private configs;
    mapping(address => uint) public changed;

    modifier onlyController(string memory identity, address actor) {
        require(isController(identity, actor), 'Not authorized');
        _;
    }

    modifier onlyControllerOrNew(string memory identity, address actor) {
        require(controllers[identity].length <= 0 || isController(identity, actor), 'Not authorized');
        _;
    }

    function getControllers(string memory identity) public view returns (address[] memory) {
        return controllers[identity];
    }

    function isController(string memory identity, address actor) public view returns (bool) {
        return actor == getController(identity);
    }

    function getController(string memory identity) public view returns (address) {
        uint len = controllers[identity].length;
        require(len > 0, "identity not found");
        if (len == 1) return controllers[identity][0];
        DIDConfig storage config = configs[identity];
        address controller = address(0);
        if( config.currentController >= len ){
            controller = controllers[identity][0];
        } else {
            controller = controllers[identity][config.currentController];
        }
        require(controller != address(0), "identity not found");
        return controller;
    }

    function setCurrentController(string memory identity, uint index) internal {
        DIDConfig storage config = configs[identity];
        config.currentController = index;
    }

    function _getControllerIndex(string memory identity, address controller) internal view returns (int) {
        for (uint i = 0; i < controllers[identity].length; i++) {
            if (controllers[identity][i] == controller) {
                return int(i);
            }
        }
        return - 1;
    }

    function addController(string memory identity, address actor, address newController) internal onlyControllerOrNew(identity, actor) {
        int controllerIndex = _getControllerIndex(identity, newController);

        if (controllerIndex < 0) {
            controllers[identity].push( newController );
        }
    }

    function removeController(string memory identity, address actor, address controller) internal onlyController(identity, actor) {
        require(controllers[identity].length > 1, 'You need at least two controllers to delete' );
        require(getController(identity) != controller , 'Cannot delete current controller' );
        int controllerIndex = _getControllerIndex(identity, controller);

        require( controllerIndex >= 0, 'Controller not exist' );

        uint len = controllers[identity].length;
        address lastController = controllers[identity][len - 1];
        controllers[identity][uint(controllerIndex)] = lastController;
        if( lastController == getController(identity) ){
            configs[identity].currentController = uint(controllerIndex);
        }
        delete controllers[identity][len - 1];
        controllers[identity].pop();
    }

    function changeController(string memory identity, address actor, address newController) internal onlyController(identity, actor) {
        int controllerIndex = _getControllerIndex(identity, newController);

        require( controllerIndex >= 0, 'Controller not exist' );

        if (controllerIndex >= 0) {
            setCurrentController(identity, uint(controllerIndex));

            emit DIDControllerChanged(identity, newController);
        }
    }

    function addController(string memory identity, address controller) external {
        addController(identity, msg.sender, controller);
    }

    function removeController(string memory identity, address controller) external {
        removeController(identity, msg.sender, controller);
    }

    function changeController(string memory identity, address newController) external {
        changeController(identity, msg.sender, newController);
    }
}
