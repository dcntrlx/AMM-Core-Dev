// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAMMPair} from "../interfaces/IAMMPair.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

contract AMMPair is IAMMPair, ERC20, ReentrancyGuardTransient {
    using Math for uint256;
    using SafeERC20 for IERC20;
    address public immutable token0;
    address public immutable token1;

    uint256 private _reserve0;
    uint256 private _reserve1;
    uint256 public immutable MINIMUM_LIQUIDITY = 1000;
    uint256 public immutable FEE_BPS = 30;

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

        _updateReserves();
    }

    function burn(address to) external {
        uint256 differenceLP = balanceOf(address(this));
        IERC20(token0).safeTransfer(to, differenceLP.mulDiv(IERC20(token0).balanceOf(address(this)), totalSupply()));
        IERC20(token1).safeTransfer(to, differenceLP.mulDiv(IERC20(token1).balanceOf(address(this)), totalSupply()));

        _burn(address(this), differenceLP);
        _updateReserves();
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "At least one output must be greater than zero");
        require(_reserve0 > amount0Out && _reserve1 > amount1Out, "AMM's reserves can cover this exchange");

        if (amount0Out > 0) {
            IERC20(token0).safeTransfer(to, amount0Out);
        }
        if (amount1Out > 0) {
            IERC20(token1).safeTransfer(to, amount1Out);
        }

        uint256 amount0In = IERC20(token0).balanceOf(address(this)) + amount0Out - _reserve0;
        uint256 amount1In = IERC20(token1).balanceOf(address(this)) + amount1Out - _reserve1;

        require(
            _reserve0 * _reserve1 * 10000 ** 2
                <= (IERC20(token0).balanceOf(address(this)) * 10000 - amount0In * FEE_BPS)
                    * (IERC20(token1).balanceOf(address(this)) * 10000 - amount1In * 3),
            "Product of tokens in pool must be constant"
        );

        _updateReserves();
    }

    function _updateReserves() internal {
        _reserve0 = IERC20(token0).balanceOf(address(this));
        _reserve1 = IERC20(token1).balanceOf(address(this));
    }
}
