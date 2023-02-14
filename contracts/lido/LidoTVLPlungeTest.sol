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
    // https://etherscan.io/address/0x9ee91F9f426fA633d227f7a9b000E28b9dfd8599
    address public constant LIDO_STMATIC = 0x9ee91F9f426fA633d227f7a9b000E28b9dfd8599;
    // https://etherscan.io/address/0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676
    address public constant CHAINLINK_MATICUSD_PRICE = 0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676;

    // initial TVL value of Lido Staking Pools
    uint256 public immutable initialTVL;
    // min accepted TVL value of Lido Staking Pools
    uint256 public immutable thresholdTVL;
    /// @param _thresholdPercentage desired max TVL plunge threshold percentage
    constructor(uint256 _thresholdPercentage) {
      require(_thresholdPercentage < 100, "Invalid threshold percentage");
      
      protocolName = "Lido";

      testedContracts = [
        address(LIDO_STETH), 
        address(CHAINLINK_ETHUSD_PRICE),
        address(LIDO_STMATIC),
        address(CHAINLINK_MATICUSD_PRICE)
      ];

      initialTVL = getCurrentTVL();
      thresholdTVL = (100 - _thresholdPercentage) * initialTVL / 100;
    }

    /// @notice test to check if TVL value of Lido Staking Pool has decreased by %X since test deployment
    /// @return true if TVL value of Lido Staking Pool has not decreased by %X since test deployment
    function checkTestPasses() public view override returns (bool) {
      
      return (getCurrentTVL() >= thresholdTVL);
    }

    /// @notice get TVL value of Lido Staking Pool
    /// @return TVL value of Lido Staking Pool
    function getCurrentTVL() public view returns (uint256) {
      uint256 stETHSupply = ILidoStETH(LIDO_STETH).totalSupply();
      uint256 stMaticSupply = IERC20Metadata(LIDO_STMATIC).totalSupply();
      return calculateValue(stETHSupply, getEthUsdPrice()) + calculateValue(stMaticSupply, getMaticUsdPrice());
    }
    /// @notice get ETH/USD price from Chainlink
    /// @return ETH/USD price from Chainlink
    function getEthUsdPrice() public view returns (uint256) {
      return uint256(IChainlinkAggregator(CHAINLINK_ETHUSD_PRICE).latestAnswer());
    }

    function getMaticUsdPrice() public view returns (uint256) {
      return uint256(IChainlinkAggregator(CHAINLINK_MATICUSD_PRICE).latestAnswer());
    }

    /// @notice calculate USD Value of provided amount at provided price
    /// @param _amount amount to calculate USD value
    /// @param _price price to calculate USD value
    /// @return USD value of provided amount at provided price
    function calculateValue(uint256 _amount, uint256 _price) internal pure returns (uint256) {
      uint256 decimals = 18;
      return (_amount * _price) / (10**decimals);
    }

    
}
