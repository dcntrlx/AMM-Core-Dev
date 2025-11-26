// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAMMPair {
    function token1() external returns (address token1) external view;
    function token2() external returns (address token2) external view;
    function mint(address to);
    function burn(address to);
    function swap(uint256 amount0out, uint256 amount1Out, address to) external;
}
