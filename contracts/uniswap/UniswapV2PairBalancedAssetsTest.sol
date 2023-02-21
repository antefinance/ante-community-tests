// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { FeedRegistryInterface } from "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import { AggregatorV2V3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";
import { Denominations } from "@chainlink/contracts/src/v0.8/Denominations.sol";

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
  address public constant FEED_REGISTRY = 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public factoryAddress;
  address public pairAddress;

  uint256 public acceptedDeviation;

  constructor(uint256 _acceptedDeviation, address _factoryAddress, address _initialTokenA, address _initialTokenB) {
    require(_factoryAddress != address(0), "UniswapV2PairBalancedAssetsTest: factory address cannot be 0x0");
    require(_acceptedDeviation > 0 &&
            _acceptedDeviation < 100, "UniswapV2PairBalancedAssetsTest: invalid accepted deviation");
    require(hasFeed(_initialTokenA), "UniswapV2PairBalancedAssetsTest: token A not supported");
    require(hasFeed(_initialTokenB), "UniswapV2PairBalancedAssetsTest: token B not supported");
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

  function tryGetEthAggregator(address _token) public view returns (AggregatorV2V3Interface) {
    try FeedRegistryInterface(FEED_REGISTRY).getFeed(_token, Denominations.ETH) returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  function tryGetBtcAggregator(address _token) public view returns (AggregatorV2V3Interface) {
    try FeedRegistryInterface(FEED_REGISTRY).getFeed(_token, Denominations.BTC) returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  function tryGetUsdAggregator(address _token) public view returns (AggregatorV2V3Interface) {
    try FeedRegistryInterface(FEED_REGISTRY).getFeed(_token, Denominations.USD) returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  function hasEthFeed(address _token) public view returns (bool){
    return address(tryGetEthAggregator(_token)) != address(0);
  }

  function hasBtcFeed(address _token) public view returns (bool){
    return address(tryGetBtcAggregator(_token)) != address(0);
  }

  function hasUsdFeed(address _token) public view returns (bool){
    return address(tryGetUsdAggregator(_token)) != address(0);
  }

  function hasFeed(address _token) public view returns (bool) {
    if(_token == WETH) {
      return true;
    }
    return hasEthFeed(_token) || hasBtcFeed(_token) || hasUsdFeed(_token);
  }
  function getUsdValue(address _token, uint256 _amount) public view returns (uint256) {
    uint256 tokenDecimals = IERC20Metadata(_token).decimals();
    uint256 tokenPrice;
    if(_token == WETH) {
      tokenPrice = uint256(FeedRegistryInterface(FEED_REGISTRY).latestAnswer(Denominations.ETH, Denominations.USD));
    } else {
      if(hasUsdFeed(_token)){
        tokenPrice = uint256(FeedRegistryInterface(FEED_REGISTRY).latestAnswer(_token, Denominations.USD));
      } else if(hasEthFeed(_token)) {
        uint256 tokenPriceEth = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(_token, Denominations.ETH));
        uint256 ethPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(Denominations.ETH, Denominations.USD));
        tokenPrice = ethPrice * tokenPriceEth / 10 ** 8;
      } else if(hasBtcFeed(_token)) {
        uint256 tokenPriceBtc = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(_token, Denominations.BTC));
        uint256 btcPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(Denominations.BTC, Denominations.USD));
        tokenPrice = btcPrice * tokenPriceBtc / 10 ** 8;
      }
    }
    return _amount * tokenPrice / (10 ** tokenDecimals);
    
  }

  function getPairReservesValues() public view returns (uint256, uint256) {
    address token0 = IUniswapV2Pair(pairAddress).token0();
    address token1 = IUniswapV2Pair(pairAddress).token1();
    (uint256 token0Balance, uint256 token1Balance,) = IUniswapV2Pair(pairAddress).getReserves();

    uint256 token0Value = getUsdValue(token0, token0Balance);
    uint256 token1Value = getUsdValue(token1, token1Balance);

    return (token0Value, token1Value);
  }

  function _setState(bytes memory _state) internal override {
    (address tokenA, address tokenB) = abi.decode(_state, (address, address));
    require(hasFeed(tokenA), "UniswapV2PairBalancedAssetsTest: token A not supported");
    require(hasFeed(tokenB), "UniswapV2PairBalancedAssetsTest: token B not supported");

    address _pair = IUniswapV2Factory(factoryAddress).getPair(tokenA, tokenB);
    require(_pair != address(0), "Pair does not exist");
    pairAddress = _pair;
  }

}