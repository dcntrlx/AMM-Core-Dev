// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAMMPair {
    function token1() external view returns (address token1);
    function token2() external view returns (address token2);
    function mint(address to) external;
    function burn(address to) external;
    function swap(uint256 amount0out, uint256 amount1Out, address to) external;
}
