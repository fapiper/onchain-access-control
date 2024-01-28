// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for value representation by group.
 */
library Groups {

    struct Map {
        mapping(bytes32 => bool) values;
    }

    /**
    * @dev adds multiple values to a map
     */
    function addBatch(
        Map storage _object,
        bytes32[] memory _values
    ) internal {
        updateBatch(_object, _values, true);
    }

    /**
    * @dev add a value to a map
     */
    function add(
        Map storage _object,
        bytes32 _value
    ) internal {
        update(_object, _value, true);
    }

    /**
    * @dev removes multiple values from a map
     */
    function removeBatch(
        Map storage _object,
        bytes32[] memory _values
    ) internal {
        updateBatch(_object, _values, false);
    }

    /**
    * @dev removes a value from a map
    */
    function remove(
        Map storage _object,
        bytes32 _value
    ) internal {
        update(_object, _value, false);
    }

    /**
    * @dev updates a value from a map
    */
    function update(
        Map storage _object,
        bytes32 _value,
        bool _exists
    ) internal {
        if(_exists != _object.values[_value]){
            _object.values[_value] = _exists;
        }
    }

    /**
    * @dev updates multiple values from a map
    */
    function updateBatch(
        Map storage _object,
        bytes32[] memory _values,
        bool _exists
    ) internal {
        for (uint256 i = 0; i < _values.length; i++) {
            update(_object, _value, _exists);
        }
    }

    /**
    * @dev has map a given value
     */
    function has(
        Map storage _object,
        bytes32 _value
    ) internal returns (bool){
        return _object[value];
    }

    /**
    * @dev has map any of given values
     */
    function hasAny(
        Map storage _object,
        bytes32[] memory _values
    ) internal returns (bool){
        for (uint256 i = 0; i < _values.length; i++) {
            if(has(_object, _values[i])){
                return true;
            }
        }
        return false;
    }

}
