// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkAggregator {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Pair is IERC20Metadata {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint256);
}

interface IGemJoin {
  function gem() external view returns (address);
}

/// @title Check TVL Value of MakerDAO UNIV2DAIUSDC MCD plunges by %X since test deployment
/// @notice Ante Test to check if MakerDAO UNIV2DAIUSDC MCD TVL value has decreased by %X since test deployment
contract MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest is AnteTest("MakerDAO UNIV2DAIUSDC MCD TVL Plunge Test") {
  
  address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  address public constant CHAINLINK_USDC_USD_PRICE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  address public constant MCD_JOIN_UNIV2DAIUSDC = 0xA81598667AC561986b70ae11bBE2dd5348ed4327;

  // initial TVL value of MakerDAO UNIV2DAIUSDC MCD
  uint256 public immutable initialTVL;
  // min accepted TVL value of MakerDAO UNIV2DAIUSDC MCD
  uint256 public immutable thresholdTVL;
  /// @param _thresholdPercentage desired max TVL plunge threshold percentage
  constructor(uint256 _thresholdPercentage) {
    require(_thresholdPercentage < 100, "Invalid threshold percentage");
    
    protocolName = "MakerDAO";
    testedContracts = [
      MCD_JOIN_UNIV2DAIUSDC,
      CHAINLINK_USDC_USD_PRICE
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
    IUniswapV2Pair pair = IUniswapV2Pair(IGemJoin(MCD_JOIN_UNIV2DAIUSDC).gem());
    address token0 = pair.token0();
    address token1 = pair.token1();
    (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
    uint256 pairAmount = pair.balanceOf(address(MCD_JOIN_UNIV2DAIUSDC));
    uint256 totalSupply = pair.totalSupply();
    
    if(token0 != DAI){
      uint256 amount = pairAmount * reserve0 / totalSupply;
      uint256 price = uint256(IChainlinkAggregator(CHAINLINK_USDC_USD_PRICE).latestAnswer());
        return calculateValue(amount, price, 8);
    }
    if(token1 != DAI){
      uint256 amount = pairAmount * reserve1 / totalSupply;
      uint256 price = uint256(IChainlinkAggregator(CHAINLINK_USDC_USD_PRICE).latestAnswer());
      return calculateValue(amount, price, 8);      
    }
    return 0;
  }

  /// @notice calculate USD Value of provided amount at provided price
  /// @param _amount amount to calculate USD value
  /// @param _price price to calculate USD value
  /// @return USD value of provided amount at provided price
  function calculateValue(uint256 _amount, uint256 _price, uint256 decimals) internal pure returns (uint256) {
    return (_amount * _price) / (10**decimals);
  }

}
