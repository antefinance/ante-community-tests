// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { FeedRegistryInterface } from "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import { AggregatorV2V3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";
import { Denominations } from "@chainlink/contracts/src/v0.8/Denominations.sol";

/// @title Library to get USD value of tokens
/// @notice This library is used to get USD value of tokens using Chainlink feeds on Ethereum Mainnet
library TokenUsdValueMainnet {
  // https://etherscan.io/address/0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf
  address public constant FEED_REGISTRY = 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
  // https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  
  /// @notice try to get the aggregator for the token's ETH price feed
  /// @param _token address of the token
  /// @return AggregatorV2V3Interface for the token's ETH price feed if it exists, otherwise address(0)
  function tryGetEthAggregator(address _token) 
    internal 
    view 
    returns (AggregatorV2V3Interface) {

    try FeedRegistryInterface(FEED_REGISTRY)
        .getFeed(_token, Denominations.ETH) 
        returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  /// @notice try to get the aggregator for the token's BTC price feed
  /// @param _token address of the token
  /// @return AggregatorV2V3Interface for the token's BTC price feed if it exists, otherwise address(0)
  function tryGetBtcAggregator(address _token) 
    internal 
    view 
    returns (AggregatorV2V3Interface) {
    
    try FeedRegistryInterface(FEED_REGISTRY)
        .getFeed(_token, Denominations.BTC) 
        returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  /// @notice try to get the aggregator for the token's USD price feed
  /// @param _token address of the token
  /// @return AggregatorV2V3Interface for the token's USD price feed if it exists, otherwise address(0)
  function tryGetUsdAggregator(address _token) 
    internal 
    view 
    returns (AggregatorV2V3Interface) {

    try FeedRegistryInterface(FEED_REGISTRY)
        .getFeed(_token, Denominations.USD) 
        returns (AggregatorV2V3Interface feed) {
      return feed;
    } catch {
      return AggregatorV2V3Interface(address(0));
    }
  }

  /// @notice check if the token has a price feed in ETH
  /// @param _token address of the token
  /// @return true if the token has a price feed in ETH, otherwise false
  function hasEthFeed(address _token) internal view returns (bool){
    return address(tryGetEthAggregator(_token)) != address(0);
  }

  /// @notice check if the token has a price feed in BTC
  /// @param _token address of the token
  /// @return true if the token has a price feed in BTC, otherwise false
  function hasBtcFeed(address _token) internal view returns (bool){
    return address(tryGetBtcAggregator(_token)) != address(0);
  }

  /// @notice check if the token has a price feed in USD
  /// @param _token address of the token
  /// @return true if the token has a price feed in USD, otherwise false
  function hasUsdFeed(address _token) internal view returns (bool){
    return address(tryGetUsdAggregator(_token)) != address(0);
  }

  /// @notice check if the token has a price feed
  /// @param _token address of the token
  /// @return true if the token has a price feed in either USD/ETH/BTC, otherwise false
  function hasFeed(address _token) internal view returns (bool) {
    /// PriceRegistry defines WETH as having a price 
    /// feed in Denominations.ETH 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    if(_token == WETH) {
      return true;
    }
    return hasEthFeed(_token) || 
            hasBtcFeed(_token) || 
            hasUsdFeed(_token);
  }

  /// @notice get the USD value of a token amount
  /// @param _token address of the token
  /// @param _amount amount of the token
  /// @return USD value of the token amount
  function getValue(address _token, uint256 _amount) internal view returns (uint256) {
    uint256 tokenDecimals = IERC20Metadata(_token).decimals();
    uint256 tokenPrice;
    /// WETH is a special case for price Feed Registry, using Denominations.ETH instead of token address
    if(_token == WETH) {
      tokenPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                          .latestAnswer(Denominations.ETH, Denominations.USD));
    } else {
      /// if a direct USD feed exists, we use that
      if(hasUsdFeed(_token)){
        tokenPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                            .latestAnswer(_token, Denominations.USD));
      } else if(hasEthFeed(_token)) {
        /// if a direct ETH feed exists, we will convert to USD through it
        uint256 tokenPriceEth = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(_token, Denominations.ETH));
        uint256 ethPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(Denominations.ETH, Denominations.USD));
        tokenPrice = ethPrice * tokenPriceEth / 10 ** 8;
      } else if(hasBtcFeed(_token)) {
        /// if a direct BTC feed exists, we will convert to USD through it
        uint256 tokenPriceBtc = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(_token, Denominations.BTC));
        uint256 btcPrice = uint256(FeedRegistryInterface(FEED_REGISTRY)
                                        .latestAnswer(Denominations.BTC, Denominations.USD));
        tokenPrice = btcPrice * tokenPriceBtc / 10 ** 8;
      }
    }
    return _amount * tokenPrice / (10 ** tokenDecimals);
    
  }
}
