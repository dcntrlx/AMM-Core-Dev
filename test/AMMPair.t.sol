// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AMMPair} from "../src/contracts/AMMPair.sol";
import {Token} from "../src/contracts/Token.sol";

contract AMMPairTest is Test {
    AMMPair public pair;
    Token public token0;
    Token public token1;

    function setUp() public {
        token0 = new Token("Token0", "TK0");
        token1 = new Token("Token1", "TK1");
        pair = new AMMPair(address(token0), address(token1));
    }

    function testPairCreation() public {
        assertEq(pair.token0(), address(token0));
        assertEq(pair.token1(), address(token1));
    }
}
