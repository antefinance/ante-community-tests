// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AnteBalanceHolderPercentageThresholdAcrossArbitrumTest Across Arbitrum
/// @notice Ante Test to check if Across Arbitrum "rugs" 70% of its top 3 tokens (as of test deployment)
contract AnteBalanceHolderPercentageThresholdAcrossArbitrumTest is AnteTest("Across does not rug 70% of its top 3 tokens") {
    
    
    address public constant POOL_ADDRESS = 0xB88690461dDbaB6f04Dfad7df66B7725942FEb9C;

    // Pool Assets
    IERC20[3] public tokens = [
      IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1), //WETH
      IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8), //USDC
      IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f) //WBTC
    ];
    
    uint256 public constant THRESHOLD = 30;

    mapping(address => uint256) public tokenThresholds;

    constructor() {
        protocolName = "Across";
        testedContracts = [POOL_ADDRESS];

        for(uint256 i = 0; i < tokens.length; i++) {
          tokenThresholds[address(tokens[i])] = (tokens[i].balanceOf(POOL_ADDRESS) * THRESHOLD) / 100;
        }
    }

    /// @notice test to check value of top 3 tokens on Across Bridge
    /// @return true if bridge has more than 30% of assets from when it was deployed
    function checkTestPasses() public view override returns (bool) {
        for(uint256 i = 0; i < tokens.length; i++) {
          if (tokens[i].balanceOf(POOL_ADDRESS) < tokenThresholds[address(tokens[i])]) {
            return false;
          }
        }
        return true;
    }
}
