// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AnteBalanceHolderPercentageThresholdBalancerArbitrumTest Balancer Arbitrum
/// @notice Ante Test to check if Balancer Arbitrum "rugs" 90% of its top 4 tokens (as of test deployment)
contract AnteBalanceHolderPercentageThresholdBalancerArbitrumTest is AnteTest("Balancer does not rug 90% of its top 4 tokens") {
    
    
    address public constant BALANCER_VAULT_ADDRESS = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    // Pool Assets
    IERC20[4] public tokens = [
      IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1), //WETH
      IERC20(0x3082CC23568eA640225c2467653dB90e9250AaA0), //RDNT
      IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f), //WBTC
      IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8) //USDC
    ];
    
    uint256 public constant THRESHOLD = 10;

    mapping(address => uint256) public tokenThresholds;

    constructor() {
        protocolName = "Balancer";
        testedContracts = [BALANCER_VAULT_ADDRESS];

        for(uint256 i = 0; i < tokens.length; i++) {
          tokenThresholds[address(tokens[i])] = (tokens[i].balanceOf(BALANCER_VAULT_ADDRESS) * THRESHOLD) / 100;
        }
    }

    /// @notice test to check value of top 3 tokens on Across Bridge
    /// @return true if bridge has more than 30% of assets from when it was deployed
    function checkTestPasses() public view override returns (bool) {
        for(uint256 i = 0; i < tokens.length; i++) {
          if (tokens[i].balanceOf(BALANCER_VAULT_ADDRESS) < tokenThresholds[address(tokens[i])]) {
            return false;
          }
        }
        return true;
    }
}
