# AMM Core Development

This repository contains the core implementation of a Constant Product Market Maker (CPMM) Automated Market Maker (AMM) and tests providing a verification for these contracts.

## Architecture
- **Token.sol**: Implementation of the ERC20 token.
- **IAMMPair.sol**: Interface for the AMM pair contract
- **AMMPair.sol**: Implementation of the CPMM pair.
- **AMMPairFactory.sol**: Factory using create2 to deploy new pairs



## Project Setup
- **Language**: Solidity ^0.8.24
- **Framework**: Foundry (Forge)
- **Libraries**: OpenZeppelin (ERC20, SafeERC20, Math, ReentrancyGuard)

## Progress Status
**Current Phase**: Phase 1: Core Logic Implementation + Tests implementation

## Plans
Phase 2: Establishing other AMM types
Phase 3: Compare to uniswap and others protocols
Phase 4: ??

## Features
- Fee on swap. (0.3%) on default