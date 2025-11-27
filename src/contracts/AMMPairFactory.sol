// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMPair} from "./AMMPair.sol";

contract AMMPairFactory {
    mapping(address => mapping(address => address)) public pairs;

    function createPair(address token0, address token1) external returns (address pair) {
        address tokenA;
        address tokenB;
        if (token0 > token1) {
            tokenA = token1;
            tokenB = token0;
        } else if (token0 == token1) {
            revert("Tokens should be different");
        } else {
            tokenA = token0;
            tokenB = token1;
        }
        require(pairs[tokenA][tokenB] == address(0), "Pair already exists");
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB)); // Contract for single pair can be deployed only once
        AMMPair newAMMPair = new AMMPair{salt: salt}(tokenA, tokenB);
        pair = address(newAMMPair);
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair; // Store both directions so lookup works either way
    }
}
