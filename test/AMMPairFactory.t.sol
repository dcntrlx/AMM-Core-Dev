// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AMMPairFactory} from "../src/contracts/AMMPairFactory.sol";

contract AMMPairFactoryTest is Test {
    AMMPairFactory public factory;

    function setUp() public {
        factory = new AMMPairFactory();
    }

    function test_createPair() public {
        address token0 = makeAddr("Token0");
        address token1 = makeAddr("Token1");
        address tokenA;
        address tokenB;
        if (token0 < token1) {
            tokenA = token0;
            tokenB = token1;
        } else {
            tokenA = token1;
            tokenB = token0;
        }
        address pair = factory.createPair(tokenA, tokenB);
        require(factory.pairs(tokenA, tokenB) == pair, "Pair address must be stored for provided tokens");
    }

    function testRevert_creatingPairWithIdenticalTokens() public {
        address token0 = makeAddr("Token"); // Separated for clarity
        address token1 = makeAddr("Token");

        vm.expectRevert();
        address pair = factory.createPair(token0, token1);
    }

    function testRevert_creatingTwoInvertedPairs() public {
        address token0 = makeAddr("Token0");
        address token1 = makeAddr("Token1");

        address pair = factory.createPair(token0, token1);
        vm.expectRevert();
        address samePair = factory.createPair(token1, token0);
    }
}
