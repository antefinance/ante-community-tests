// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AnteBalanceHolderPercentageThresholdAbracadabraArbitrumTest Abracadabra Arbitrum
/// @notice Ante Test to check if Abracadabra Arbitrum "rugs" 70% of its top 3 tokens (as of test deployment)
contract AnteBalanceHolderPercentageThresholdAbracadabraArbitrumTest is AnteTest("Abracadabra does not rug 70% of its top 3 tokens") {
    
    
    address public constant BENTO_BOX = 0x74c764D41B77DBbb4fe771daB1939B00b146894A;

    // Pool Assets
    IERC20[3] public tokens = [
      IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1), //WETH
      IERC20(0x3082CC23568eA640225c2467653dB90e9250AaA0), //RDNT
      IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8) //USDC
    ];
    
    uint256 public constant THRESHOLD = 30;

    mapping(address => uint256) public tokenThresholds;

    constructor() {
        protocolName = "Abracadabra";
        testedContracts = [BENTO_BOX];

        for(uint256 i = 0; i < tokens.length; i++) {
          tokenThresholds[address(tokens[i])] = (tokens[i].balanceOf(BENTO_BOX) * THRESHOLD) / 100;
        }
    }

    /// @notice test to check value of top 3 tokens on Across Bridge
    /// @return true if bridge has more than 30% of assets from when it was deployed
    function checkTestPasses() public view override returns (bool) {
        for(uint256 i = 0; i < tokens.length; i++) {
          if (tokens[i].balanceOf(BENTO_BOX) < tokenThresholds[address(tokens[i])]) {
            return false;
          }
        }
        return true;
    }
}
