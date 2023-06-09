// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Check if Arbitrum GMX Vault balance of WETH dropped 99% or more
/// @notice Ante Test to check if Arbitrum GMX Vault WETH balance dropped 99% or more
contract ArbitrumGMXRugPullWETHTest is 
        AnteTest("Arbitrum GMX Rug Pull Test On All Whitelisted Tokens") {
  
  // https://arbiscan.io/address/0x489ee077994B6658eAfA855C308275EAd8097C4A#code
  address constant public GMX_VAULT = 0x489ee077994B6658eAfA855C308275EAd8097C4A;

  // https://arbiscan.io/address/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1#code
  IERC20 constant public WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

  // will hold the last known balance of WETH in GMX Vault
  uint256 public immutable balanceAtDeployment;
  
  constructor() {
        
    protocolName = "GMX";

    testedContracts = [
      GMX_VAULT
    ];
    
    balanceAtDeployment = WETH.balanceOf(GMX_VAULT);
  }

  /// @notice test to check if average balances dropped 99% or more
  /// @return true if average balances dropped 99% or more
  function checkTestPasses() external view override returns (bool) {
  
      uint256 percentageRemaining = _getBalancePercentageRemaining();
      // if average balance dropped 99% or more
      // test fails
      return percentageRemaining > 1;

  }

  /// @notice Get the average percentage remaining of WETH in GMX Vault since contract deployment
  /// @return average percentage remaining of all tokens in GMX Vault
  function _getBalancePercentageRemaining() internal view returns (uint256) {
  
    uint256 currentBalance = WETH.balanceOf(GMX_VAULT);

    if(currentBalance >= balanceAtDeployment){
      return 100;
    }

    uint256 decreaseDelta = balanceAtDeployment - currentBalance;
    uint256 decreaseDeltaPercentage = decreaseDelta * 100 / balanceAtDeployment;

    return 100 - decreaseDeltaPercentage;
    
  }

}
