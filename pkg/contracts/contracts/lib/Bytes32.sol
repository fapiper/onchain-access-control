// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/**
 * @dev Library for lists of byte32 value.
 */
library Bytes32 {
    struct Set {
        mapping(bytes32 => uint256) map;
        bytes32[] list;
    }

    /**
     * @dev add a value
     */
    function add(Set storage _obj, bytes32 _assignerRole) internal {
        if (_obj.map[_assignerRole] == 0) {
            _obj.list.push(_assignerRole);
            _obj.map[_assignerRole] = _obj.list.length;
        }
    }

    /**
     * @dev remove an value for this role
     */
    function remove(Set storage _obj, bytes32 _assignerRole) internal {
        uint256 idx = _obj.map[_assignerRole];

        if (idx > 0) {
            uint256 actualIdx = idx - 1;

            // replace item to remove with last item in list and update mappings
            if (_obj.list.length - 1 > actualIdx) {
                _obj.list[actualIdx] = _obj.list[_obj.list.length - 1];
                _obj.map[_obj.list[actualIdx]] = actualIdx + 1;
            }

            _obj.list.pop();
            _obj.map[_assignerRole] = 0;
        }
    }

    /**
     * @dev remove all values
     */
    function clear(Set storage _obj) internal {
        for (uint256 i = 0; i < _obj.list.length; i += 1) {
            _obj.map[_obj.list[i]] = 0;
        }

        delete _obj.list;
    }

    /**
     * @dev get no. of values
     */
    function size(Set storage _obj) internal view returns (uint256) {
        return _obj.list.length;
    }

    /**
     * @dev get whether value exists.
     */
    function has(Set storage _obj, bytes32 _value) internal view returns (bool) {
        return 0 < _obj.map[_value];
    }

    /**
     * @dev get value at index.
     */
    function get(Set storage _obj, uint256 _index) internal view returns (bytes32) {
        return _obj.list[_index];
    }

    /**
     * @dev Get all values.
     */
    function getAll(Set storage _obj) internal view returns (bytes32[] storage) {
        return _obj.list;
    }
}
