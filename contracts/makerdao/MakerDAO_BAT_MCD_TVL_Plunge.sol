// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkAggregator {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint8);
}

interface IGemJoin {
  function gem() external view returns (address);
}

/// @title Check TVL Value of MakerDAO BAT MCD plunges by %X since test deployment
/// @notice Ante Test to check if MakerDAO BAT MCD TVL value has decreased by %X since test deployment
contract MakerDAOBATMCDTVLPlungeTest is AnteTest("MakerDAO BAT MCD TVL Plunge Test") {
  address public constant CHAINLINK_BAT_ETH_PRICE = 0x0d16d4528239e9ee52fa531af613AcdB23D88c94;
  address public constant CHAINLINK_ETH_USD_PRICE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  address public constant BAT_MCD_JOIN = 0x3D0B1912B66114d4096F48A8CEe3A56C231772cA;

  // initial TVL value of Lido Staking Pools
  uint256 public immutable initialTVL;
  // min accepted TVL value of Lido Staking Pools
  uint256 public immutable thresholdTVL;
  /// @param _thresholdPercentage desired max TVL plunge threshold percentage
  constructor(uint256 _thresholdPercentage) {
    require(_thresholdPercentage < 100, "Invalid threshold percentage");
    
    protocolName = "MakerDAO";
    testedContracts = [
      CHAINLINK_BAT_ETH_PRICE,
      CHAINLINK_ETH_USD_PRICE,
      BAT_MCD_JOIN
    ];

    initialTVL = getCurrentTVL();
    thresholdTVL = (100 - _thresholdPercentage) * initialTVL / 100;
  }
  /// @notice test to check if TVL value of MakerDAO has decreased by %X since test deployment
  /// @return true if TVL value of MakerDAO has not decreased by %X since test deployment
  function checkTestPasses() public view override returns (bool) {
    
    return (getCurrentTVL() >= thresholdTVL);
  }

  function getCurrentTVL() public view returns (uint256) {
    address _tokenAddress = IGemJoin(BAT_MCD_JOIN).gem();
    IERC20Metadata token = IERC20Metadata(_tokenAddress);
    uint256 amount = token.balanceOf(BAT_MCD_JOIN);
    uint256 decimals = uint256(token.decimals());
    uint256 batPriceInETH = uint256(IChainlinkAggregator(CHAINLINK_BAT_ETH_PRICE).latestAnswer());
    uint256 amountValueInETH = calculateValue(amount, batPriceInETH, 18);
    uint256 ethPriceInUSD = uint256(IChainlinkAggregator(CHAINLINK_ETH_USD_PRICE).latestAnswer());
    return calculateValue(amountValueInETH, ethPriceInUSD, decimals);
  }

  /// @notice calculate USD Value of provided amount at provided price
  /// @param _amount amount to calculate USD value
  /// @param _price price to calculate USD value
  /// @return USD value of provided amount at provided price
  function calculateValue(uint256 _amount, uint256 _price, uint256 decimals) internal pure returns (uint256) {
    return (_amount * _price) / (10**decimals);
  }

}
