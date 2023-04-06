// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AnteBalanceHolderPercentageThresholdTest Across Optimism
/// @notice Ante Test to check if Across Optimism "rugs" 70% of its top 3 tokens (as of test deployment)
contract AnteBalanceHolderPercentageThresholdTest is AnteTest("Across does not rug 70% of its top 3 tokens") {
    
    
    address public constant POOL_ADDRESS = 0xa420b2d1c0841415A695b81E5B867BCD07Dff8C9;

    // Pool Assets
    IERC20[3] public tokens = [
      IERC20(0x4200000000000000000000000000000000000006), //WETH
      IERC20(0x7F5c764cBc14f9669B88837ca1490cCa17c31607), //USDC
      IERC20(0x68f180fcCe6836688e9084f035309E29Bf0A2095) //WBTC
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
