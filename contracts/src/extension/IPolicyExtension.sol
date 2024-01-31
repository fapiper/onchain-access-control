// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IPolicyExtension {

    struct Policy {
        bytes32 context;
        bytes32 id;
        address instance;
        bytes4 verify;
        bool exists;
    }
}
