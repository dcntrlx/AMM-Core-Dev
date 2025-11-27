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
        if (pair.token0() == address(token1)) {
            (token0, token1) = (token1, token0);
        }
    }

    function setUp() public {
        _createAMMPairFactory();
        _createTokens();
        _createPair();
    }

    function _mintPair() internal returns (uint256 liquidity, uint256 amountToken0, uint256 amountToken1) {
        address liquidityProvider = makeAddr("liquidityProvider");
        amountToken0 = 1 * 10 ** 3;
        amountToken1 = 3 * 10 ** 6;
        deal(address(token0), liquidityProvider, amountToken0);
        deal(address(token1), liquidityProvider, amountToken1);

        vm.startPrank(liquidityProvider);

        token0.transfer(address(pair), amountToken0);
        token1.transfer(address(pair), amountToken1);
        liquidity = pair.mint(liquidityProvider);

        assertEq(
            liquidity,
            Math.sqrt(amountToken0 * amountToken1) - MINIMUM_LIQUIDITY,
            "Liquidity minted should match formula"
        );
        vm.stopPrank();
    }

    function test_mintPair() public {
        _mintPair();
    }

    function test_burnPair() public {
        address liquidityProvider = makeAddr("liquidityProvider");
        (uint256 liquidity, uint256 amountToken0, uint256 amountToken1) = _mintPair();

        vm.startPrank(liquidityProvider);
        pair.transfer(address(pair), liquidity);
        (uint256 amount0Out, uint256 amount1Out) = pair.burn(liquidityProvider);

        assertEq(pair.balanceOf(liquidityProvider), 0, "Balance in LP of liquidityProvider after burn must be 0");

        uint256 totalSupply = liquidity + MINIMUM_LIQUIDITY;
        uint256 expectedAmount0 = Math.mulDiv(liquidity, amountToken0, totalSupply);
        uint256 expectedAmount1 = Math.mulDiv(liquidity, amountToken1, totalSupply);

        assertEq(amount0Out, expectedAmount0, "Amount0 out should match proportional share");
        assertEq(amount1Out, expectedAmount1, "Amount1 out should match proportional share");
    }

    function test_swapPair() public {
        uint256 amount0Out = 2;
        uint256 amount1Out = 0;
        uint256 amount1In = 6100;
        address user = makeAddr("User");

        _mintPair();
        deal(address(token1), user, amount1In);

        vm.startPrank(user);
        token1.transfer(address(pair), amount1In);
        pair.swap(amount0Out, amount1Out, user);

        assertEq(token0.balanceOf(user), amount0Out, "User should receive exact amount0Out");
        assertEq(token1.balanceOf(user), 0, "User sent all token1");
    }
}

