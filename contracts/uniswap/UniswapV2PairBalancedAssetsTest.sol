// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
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

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}


/// @title Check if Uniswap V2 Pair has balanced assets
/// @notice Ante Test to check if Uniswap V2 Pair has balanced assets
contract UniswapV2PairBalancedAssetsTest is AnteTest("Uniswap V2 Pair Balanced Assets Test") {

  address public factoryAddress;
  address public pairAddress;

  uint256 public acceptedDeviation;

  mapping (address => address) public chainlinkFeedUSD;

  constructor(uint256 _acceptedDeviation, address _factoryAddress, address _initialTokenA, address _initialTokenB) {
    require(_factoryAddress != address(0), "UniswapV2PairBalancedAssetsTest: factory address cannot be 0x0");
    require(_acceptedDeviation > 0 &&
            _acceptedDeviation < 100, "UniswapV2PairBalancedAssetsTest: invalid accepted deviation");
    
    factoryAddress = _factoryAddress;

    // Set initial pair address
    pairAddress = IUniswapV2Factory(factoryAddress).getPair(_initialTokenA, _initialTokenB);
    require(pairAddress != address(0), "UniswapV2PairBalancedAssetsTest: pair address cannot be 0x0");
    
    protocolName = "Uniswap V2";
    

    // CHAINLINK FEED ETH / USD for token WETH
    chainlinkFeedUSD[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // CHAINLINK FEED COMP / USD for token COMP
    chainlinkFeedUSD[0xc00e94Cb662C3520282E6f5717214004A7f26888] = 0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5;

    // CHAINLINK FEED KNC / USD for token KNC
    chainlinkFeedUSD[0xdd974D5C2e2928deA5F71b9825b8b646686BD200] = 0xf8fF43E991A81e6eC886a3D281A2C6cC19aE70Fc;

    // CHAINLINK FEED LINK / USD for token LINK
    chainlinkFeedUSD[0x514910771AF9Ca656af840dff83E8264EcF986CA] = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c;
    
    // CHAINLINK FEED MANA / USD for token MANA
    chainlinkFeedUSD[0x0F5D2fB29fb7d3CFeE444a200298f468908cC942] = 0x56a4857acbcfe3a66965c251628B1c9f1c408C19;

    // CHAINLINK FEED USDP / USD for token USDP
    chainlinkFeedUSD[0x8E870D67F660D95d5be530380D0eC0bd388289E1] = 0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3;

    // CHAINLINK FEED TUSD / USD for token TUSD
    chainlinkFeedUSD[0x0000000000085d4780B73119b644AE5ecd22b376] = 0xec746eCF986E2927Abd291a2A1716c940100f8Ba;

    // CHAINLINK FEED USDC / USD for token USDC
    chainlinkFeedUSD[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    // CHAINLINK FEED USDT / USD for token USDT
    chainlinkFeedUSD[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;

    // CHAINLINK FEED ZRX / USD for token ZRX
    chainlinkFeedUSD[0xE41d2489571d322189246DaFA5ebDe1F4699F498] = 0x2885d15b8Af22648b98B122b22FDF4D2a56c6023;

    // CHAINLINK FEED BAL / USD for token BAL
    chainlinkFeedUSD[0xba100000625a3754423978a60c9317c58a424e3D] = 0xdF2917806E30300537aEB49A7663062F4d1F2b5F;

    // CHAINLINK FEED YFI / USD for token YFI
    chainlinkFeedUSD[0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e] = 0xA027702dbb89fbd58938e4324ac03B58d812b0E1;

    // CHAINLINK FEED GUSD / USD for token GUSD
    chainlinkFeedUSD[0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd] = 0xa89f5d2365ce98B3cD68012b6f503ab1416245Fc;

    // CHAINLINK FEED UNI / USD for token UNI
    chainlinkFeedUSD[0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984] = 0x553303d460EE0afB37EdFf9bE42922D8FF63220e;

    // CHAINLINK FEED BTC / USD for token WBTC
    chainlinkFeedUSD[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;

    // CHAINLINK FEED AAVE / USD for token AAVE
    chainlinkFeedUSD[0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9] = 0x547a514d5e3769680Ce22B2361c10Ea13619e8a9;

    // CHAINLINK FEED MATIC / USD for token MATIC
    chainlinkFeedUSD[0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0] = 0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676;

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

    uint256 token0Decimals = IERC20Metadata(token0).decimals();
    uint256 token1Decimals = IERC20Metadata(token1).decimals();

    uint256 token0Price = uint256(IChainlinkAggregator(chainlinkFeedUSD[token0]).latestAnswer());
    uint256 token1Price = uint256(IChainlinkAggregator(chainlinkFeedUSD[token1]).latestAnswer());

    uint256 token0Value = token0Balance * token0Price / (10 ** token0Decimals);
    uint256 token1Value = token1Balance * token1Price / (10 ** token1Decimals);

    return (token0Value, token1Value);
  }

  function _setState(bytes memory _state) internal override {
    (address tokenA, address tokenB) = abi.decode(_state, (address, address));
    require(chainlinkFeedUSD[tokenA] != address(0), "Token A not supported");
    require(chainlinkFeedUSD[tokenB] != address(0), "Token B not supported");
    address _pair = IUniswapV2Factory(factoryAddress).getPair(tokenA, tokenB);
    require(_pair != address(0), "Pair does not exist");
    pairAddress = _pair;
  }

}