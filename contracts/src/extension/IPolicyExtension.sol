// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../policy/IPolicyVerifier.sol";

interface IPolicyExtension {

    struct Policy {
        bytes32 context;
        bytes32 id;
        IPolicyVerifier verifier;
        bool exists;
    }
}
