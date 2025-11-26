// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAMMPair} from "../interfaces/IAMMPair.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AMMPair is IAMMPair, ERC20 {
    using Math for uint256;
    address public immutable token0;
    address public immutable token1;

    uint256 private _reserve0;
    uint256 private _reserve1;
    uint256 public immutable MINIMUM_LIQUIDITY = 1000;

    constructor(address _token0, address _token1) ERC20("LiquidityProviderToken", "LPT") {
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to) external override {
        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));
        uint256 differenceToken0 = token0Balance - _reserve0;
        uint256 differenceToken1 = token1Balance - _reserve1;
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            uint256 liquidity = Math.sqrt(differenceToken0 * differenceToken1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
            _mint(to, liquidity);
        } else {
            _mint(
                to,
                Math.min(
                    totalSupply.mulDiv(differenceToken0, _reserve0), totalSupply.mulDiv(differenceToken1, _reserve1)
                )
            );
        }

        _reserve0 = IERC20(token0).balanceOf(address(this));
        _reserve1 = IERC20(token1).balanceOf(address(this));
    }
}
