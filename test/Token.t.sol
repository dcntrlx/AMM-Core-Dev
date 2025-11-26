// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/contracts/Token.sol";

contract TokenTest is Test {
    address public token;
    address public tokenCreator = makeAddr("TokenCreator");

    function setUp() public {
        vm.startPrank(tokenCreator);
        string memory tokenName = "TestToken";
        string memory tokenSymbol = "TT";
        Token _token = new Token(tokenName, tokenSymbol);
        token = address(_token);
        vm.stopPrank();
    }

    function test_tokenCreation() public {
        uint256 amount = 100000;
        address receiver = makeAddr("Mint receiver");
        vm.prank(tokenCreator);
        Token(token).mint(receiver, amount);
        vm.assertEq(Token(token).balanceOf(receiver), amount, "Minted tokens not equal to requested amount");
    }
}
