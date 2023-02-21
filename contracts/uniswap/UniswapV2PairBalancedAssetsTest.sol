// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {TokenUsdValueMainnet} from "../libraries/chainlink/TokenUsdValueMainnet.sol";

interface IUniswapV2Pair is IERC20Metadata {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint256);
}

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}


/// @title Check if Uniswap V2 Pair has balanced assets
/// @notice Ante Test to check if Uniswap V2 Pair has balanced assets
contract UniswapV2PairBalancedAssetsTest is AnteTest("Uniswap V2 Pair Balanced Assets Test") {
  using TokenUsdValueMainnet for address;
  address public factoryAddress;
  address public pairAddress;

  uint256 public acceptedDeviation;

  constructor(uint256 _acceptedDeviation, address _factoryAddress, address _initialTokenA, address _initialTokenB) {
    require(_factoryAddress != address(0), "UniswapV2PairBalancedAssetsTest: factory address cannot be 0x0");
    require(_acceptedDeviation > 0 &&
            _acceptedDeviation < 100, "UniswapV2PairBalancedAssetsTest: invalid accepted deviation");
    require(_initialTokenA.hasFeed(), "UniswapV2PairBalancedAssetsTest: token A not supported");
    require(_initialTokenB.hasFeed(), "UniswapV2PairBalancedAssetsTest: token B not supported");
    factoryAddress = _factoryAddress;

    // Set initial pair address
    pairAddress = IUniswapV2Factory(factoryAddress).getPair(_initialTokenA, _initialTokenB);
    require(pairAddress != address(0), "UniswapV2PairBalancedAssetsTest: pair address cannot be 0x0");
    
    protocolName = "Uniswap V2";

    testedContracts = [
      factoryAddress
    ];

  }

  function getStateTypes() external pure override returns (string memory) {
      return "address,address";
  }

  function getStateNames() external pure override returns (string memory) {
      return "addressTokenA,addressTokenB";
  }

  /// @notice test to check if the tested pair has balanced reserves
  /// @return true if the pair has balanced reserves
  function checkTestPasses() public view override returns (bool) {

    (uint256 token0Value, uint256 token1Value) = getPairReservesValues();

    (uint256 valueDiff, uint256 value) = token0Value > token1Value 
                                      ? (token0Value - token1Value, token0Value) 
                                      : (token1Value - token0Value, token1Value);
    
    return valueDiff * 100 / value <= acceptedDeviation;

  }

  function getPairReservesValues() public view returns (uint256, uint256) {
    address token0 = IUniswapV2Pair(pairAddress).token0();
    address token1 = IUniswapV2Pair(pairAddress).token1();
    (uint256 token0Balance, uint256 token1Balance,) = IUniswapV2Pair(pairAddress).getReserves();

    uint256 token0Value = token0.getValue(token0Balance);
    uint256 token1Value = token1.getValue(token1Balance);

    return (token0Value, token1Value);
  }

  function _setState(bytes memory _state) internal override {
    (address tokenA, address tokenB) = abi.decode(_state, (address, address));
    require(tokenA.hasFeed(), "UniswapV2PairBalancedAssetsTest: token A not supported");
    require(tokenB.hasFeed(), "UniswapV2PairBalancedAssetsTest: token B not supported");

    address _pair = IUniswapV2Factory(factoryAddress).getPair(tokenA, tokenB);
    require(_pair != address(0), "Pair does not exist");
    pairAddress = _pair;
  }

}