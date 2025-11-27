// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {Token} from "../src/contracts/Token.sol";
import {AMMPair} from "../src/contracts/AMMPair.sol";
import {AMMPairFactory} from "../src/contracts/AMMPairFactory.sol";
import {AMMPair as Pair} from "../src/contracts/AMMPair.sol";

contract AMMIntegration is Test {
    uint256 public constant MINIMUM_LIQUIDITY = 1000;
    Token public token0;
    Token public token1;
    AMMPairFactory public factory;
    Pair public pair;

    address public tokenDeployer;

    function _createAMMPairFactory() public {
        factory = new AMMPairFactory();
    }

    function _createTokens() public {
        vm.startPrank(tokenDeployer);
        token0 = new Token("Ethereum", "ETH");
        token1 = new Token("USDC", "USDC");
    }

    function _createPair() public {
        pair = Pair(factory.createPair(address(token0), address(token1)));
    }

    function setUp() public {
        _createAMMPairFactory();
        _createTokens();
        _createPair();
    }

    function _mintPair() internal {
        address liquidityProvider = makeAddr("liquidityProvider");
        uint256 amountToken0 = 1 * 10 ** 3;
        uint256 amountToken1 = 3 * 10 ** 6;
        deal(address(token0), liquidityProvider, amountToken0);
        deal(address(token1), liquidityProvider, amountToken1);

        vm.startPrank(liquidityProvider);

        token0.transfer(address(pair), amountToken0);
        token1.transfer(address(pair), amountToken1);
        uint256 liquidity = pair.mint(liquidityProvider);
        require(
            liquidity == Math.sqrt(amountToken0 * amountToken1) - MINIMUM_LIQUIDITY,
            "Math formula for minting must be correct"
        );
        console.log("Liquidity: ", liquidity);
    }

    function test_mintPair() public {
        _mintPair();
    }

    function test_burnPair() public {
        address liquidityProvider = makeAddr("liquidityProvider");
        _mintPair();
        vm.startPrank(liquidityProvider);
        pair.transfer(address(pair), pair.balanceOf(liquidityProvider));
        (uint256 amount0Out, uint256 amount1Out) = pair.burn(liquidityProvider);
        console.log(amount0Out, amount1Out);
        assertEq(pair.balanceOf(liquidityProvider), 0, "Balance in LP of liquidityProvider after burn must be 0");
        assertTrue(
            amount0Out >= 2945227 && amount1Out >= 981, "Balances in tokens after burn should be constrained by: "
        );
    }
}

