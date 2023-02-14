// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkAggregator {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint8);
}

interface ILidoStETH {
  function totalSupply() external view returns (uint256);
}

/// @title Check TVL Value of Lido Staking Pool plunges by %X since test deployment
/// @notice Ante Test to check if Lido Staking Pool TVL value has decreased by %X since test deployment
contract LidoTVLPlungeTest is AnteTest("Lido TVL Plunge Test") {
    // https://etherscan.io/address/0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
    address public constant LIDO_STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    // https://etherscan.io/address/0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    address public constant CHAINLINK_ETHUSD_PRICE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    // Desired max TVL plunge threshold percentage
    uint256 public immutable thresholdPercentage;
    uint256 public immutable maxPercentage;

    uint256 public immutable initialTVL;

    /// @param _thresholdPercentage desired max TVL plunge threshold percentage
    /// @param _maxPercentage desired max TVL plunge percentage
    constructor(uint256 _thresholdPercentage, uint256 _maxPercentage) {
      require(_thresholdPercentage < _maxPercentage, "Invalid threshold percentage");
      thresholdPercentage = _thresholdPercentage;
      maxPercentage = _maxPercentage;
      
      protocolName = "Lido";

      testedContracts = [address(LIDO_STETH), address(CHAINLINK_ETHUSD_PRICE)];

      initialTVL = getCurrentTVL();
    }

    /// @notice get TVL value of Lido Staking Pool
    /// @return TVL value of Lido Staking Pool
    function getCurrentTVL() public view returns (uint256) {
      uint256 stETHSupply = ILidoStETH(LIDO_STETH).totalSupply();
      
      return calculateValue(stETHSupply);
    }
    /// @notice get ETH/USD price from Chainlink
    /// @return ETH/USD price from Chainlink
    function getEthUsdPrice() public view returns (uint256) {
      return uint256(IChainlinkAggregator(CHAINLINK_ETHUSD_PRICE).latestAnswer());
    }

    /// @notice get decimals of ETH/USD price from Chainlink
    /// @return decimals of ETH/USD price from Chainlink
    function ethPriceDecimals() public view returns (uint256) {
      return uint256(IChainlinkAggregator(CHAINLINK_ETHUSD_PRICE).decimals());
    }

    /// @notice calculate USD Value of provided ETH amount
    /// @param _ethAmount amount of ETH to calculate USD value of
    /// @return USD value of provided ETH amount
    function calculateValue(uint256 _ethAmount) public view returns (uint256) {
      uint256 ethPrice = getEthUsdPrice();
      uint256 decimals = 18;
      return (_ethAmount * ethPrice) / (10**decimals);
    }

    /// @notice get TVL value of Lido Staking Pool at which test will fail
    /// @return TVL value of Lido Staking Pool at which test will fail
    function thresholdTVL() public view returns (uint256) {
      return (initialTVL * (maxPercentage - thresholdPercentage)) / maxPercentage;
    }

    /// @notice test to check if TVL value of Lido Staking Pool has decreased by %X since test deployment
    /// @return true if TVL value of Lido Staking Pool has not decreased by %X since test deployment
    function checkTestPasses() public view override returns (bool) {
      uint256 currentTVL = getCurrentTVL();
      if(currentTVL > initialTVL) {
        return true;
      }
      return (currentTVL >= thresholdTVL());
    }
}
