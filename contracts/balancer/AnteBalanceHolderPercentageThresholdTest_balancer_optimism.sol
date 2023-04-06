// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AnteBalanceHolderPercentageThresholdTest Balancer Optimism
/// @notice Ante Test to check if Balancer Optimism "rugs" 90% of its top 6 tokens (as of test deployment)
contract AnteBalanceHolderPercentageThresholdTest is AnteTest("Balancer does not rug 90% of its top 6 tokens") {
    
    
    address public constant BALANCER_VAULT_ADDRESS = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    // Pool Assets
    IERC20[6] public tokens = [
      IERC20(0x7F5c764cBc14f9669B88837ca1490cCa17c31607), //USDC
      IERC20(0x4200000000000000000000000000000000000006), //WETH
      IERC20(0x296F55F8Fb28E498B858d0BcDA06D955B2Cb3f97), //STG
      IERC20(0x68f180fcCe6836688e9084f035309E29Bf0A2095), //WBTC
      IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1), //DAI
      IERC20(0x4200000000000000000000000000000000000042) //OP
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
