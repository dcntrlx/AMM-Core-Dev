// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMPair} from "./AMMPair.sol";

contract AMMPairFactory {
    mapping(address => mapping(address => address)) public pairs;

    function createPair(address token0, address token1) external returns (address pair) {
        bytes32 salt = keccak256(abi.encodePacked(token0, token1)); // Contract for single pair can be deployed only once
        AMMPair newAMMPair = new AMMPair{salt: salt}(token0, token1);
        pair = address(newAMMPair);
        pairs[token0][token1] = pair;
    }
}
