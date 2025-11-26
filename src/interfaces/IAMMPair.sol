// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAMMPair {
    function token0() external view returns (address token0);
    function token1() external view returns (address token1);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0Out, uint256 amount1Out);
    function swap(uint256 amount0out, uint256 amount1Out, address to) external;
}
