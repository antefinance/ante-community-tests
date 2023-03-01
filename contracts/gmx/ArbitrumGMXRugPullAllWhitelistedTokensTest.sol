// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGMXVault {
  function allWhitelistedTokens(uint256 index) external view returns (address);
  function allWhitelistedTokensLength() external view returns (uint256);
}

error GMXRugPullDetected();

/// @title Check if Arbitrum GMX Vault balances dropped 99% or more
/// @notice Ante Test to check if Arbitrum GMX Vault balances dropped 99% or more
contract ArbitrumGMXRugPullAllWhitelistedTokensTest is 
        AnteTest("Arbitrum GMX Rug Pull Test On All Whitelisted Tokens") {
  
  // https://arbiscan.io/address/0x489ee077994B6658eAfA855C308275EAd8097C4A#code
  IGMXVault constant public GMX_VAULT_ADDRESS = IGMXVault(0x489ee077994B6658eAfA855C308275EAd8097C4A);

  // will hold the last known balances of all tokens in GMX Vault
  mapping(address=>uint256) public lastBalances;
  address[] private tokens;
  constructor() {
        
    protocolName = "GMX";

    testedContracts = [
      address(GMX_VAULT_ADDRESS)
    ];
    
    _updateVaultBalances();
  }


  function getStateTypes() external pure override returns (string memory) {
      return "bool";
  }

  function getStateNames() external pure override returns (string memory) {
      return "updateFlag";
  }

  /// @notice test to check if average balances dropped 99% or more
  /// @return true if average balances dropped 99% or more
  function checkTestPasses() public view override returns (bool) {
  
      uint256 averagePercentageRemaining = _getAveragePercentageRemaining();
      // if average balance dropped 99% or more
      // test fails
      return averagePercentageRemaining > 1;

  }

  function _updateVaultBalances() internal {
    uint256 length = GMX_VAULT_ADDRESS.allWhitelistedTokensLength();
    tokens = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      address token = GMX_VAULT_ADDRESS.allWhitelistedTokens(i);
      lastBalances[token] = IERC20Metadata(token).balanceOf(address(GMX_VAULT_ADDRESS));
      tokens[i] = token;
    }
  }

  function _setState(bytes memory _state) internal override {
    (bool updateKnownVaultBalances) = abi.decode(_state, (bool));

    if(updateKnownVaultBalances){
      // before updating balances
      // check if we are not in a rug pull
      if(!checkTestPasses()){
        revert GMXRugPullDetected();
      }
      _updateVaultBalances();
    }

  }

  /// @notice Get the average percentage remaining of all tokens in GMX Vault since last balances state update
  /// @return average percentage remaining of all tokens in GMX Vault
  function _getAveragePercentageRemaining() internal view returns (uint256) {
    uint256 length = tokens.length;

    uint256 averagePercentageRemaining = 0;

    for (uint256 i = 0; i < length; i++) {
      address token = tokens[i];
      uint256 lastBalance = lastBalances[token];
      uint256 currentBalance = IERC20Metadata(token).balanceOf(address(GMX_VAULT_ADDRESS));
      
      // if known balance is 0 either it's a new token or previous balance was 0
      // in both cases we can't calculate the delta
      if(lastBalance == 0){
        continue;
      }

      // balance increased
      if(lastBalance < currentBalance) {
        uint256 increaseDelta = currentBalance - lastBalance;
        uint256 increaseDeltaPercentage = increaseDelta * 100 / lastBalance;
        averagePercentageRemaining += 100 + increaseDeltaPercentage;
      } else {
        uint256 decreaseDelta = lastBalance - currentBalance;
        uint256 decreaseDeltaPercentage = decreaseDelta * 100 / lastBalance;
        averagePercentageRemaining += 100 - decreaseDeltaPercentage;
      }
    }

    if(length == 0) {
      return 0;
    }

    averagePercentageRemaining /= length;

    return averagePercentageRemaining;
  }

}
