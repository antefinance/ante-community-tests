// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkAggregator {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint8);
}

interface IRenBTC is IERC20Metadata {
  function balanceOfUnderlying(address account) external view returns (uint256);
}

interface IRETH is IERC20Metadata {
  function getEthValue(uint256 _rethAmount) external view returns (uint256);
}

interface IWSTETH is IERC20Metadata {
  function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);
  function stETH() external view returns (address);
}

interface IStETH is IERC20Metadata {
  function getPooledEthByShares(uint256 _stETHAmount) external view returns (uint256);
}

interface IUniswapV2Pair is IERC20Metadata {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint256);
}

interface IGUniV3Pair is IERC20Metadata {
  function totalSupply() external view returns (uint256);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getUnderlyingBalances() external view returns (uint256, uint256);
}

interface IGemJoin {
  function gem() external view returns (address);
}

/// @title Check TVL Value of MakerDAO plunges by %X since test deployment
/// @notice Ante Test to check if MakerDAO TVL value has decreased by %X since test deployment
contract MakerDAOTVLPlungeTest is AnteTest("MakerDAO TVL Plunge Test") {
  address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  address public constant RENBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
  address public constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
  address public constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
  address public btcToUsdDataFeed = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;

  address[] public regularMcdJoins;
  address[] public univ2McdJoins;
  address[] public guniv3McdJoins;

  mapping(address => address) public dataFeedsUSD;
  mapping(address => address) public dataFeedsETH;
  mapping(address => address) public dataFeedsBTC;
  // initial TVL value of MakerDAO 
  uint256 public immutable initialTVL;
  // min accepted TVL value of MakerDAO
  uint256 public immutable thresholdTVL;
  /// @param _thresholdPercentage desired max TVL plunge threshold percentage
  constructor(uint256 _thresholdPercentage) {
    require(_thresholdPercentage < 100, "Invalid threshold percentage");
    
    protocolName = "MakerDAO";
    // CHAINLINK FEED BAT / ETH for token BAT
    dataFeedsETH[0x0D8775F648430679A709E98d2b0Cb6250d2887EF] = 0x0d16d4528239e9ee52fa531af613AcdB23D88c94;

    // CHAINLINK FEED COMP / USD for token COMP
    dataFeedsUSD[0xc00e94Cb662C3520282E6f5717214004A7f26888] = 0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5;

    // CHAINLINK FEED ETH / USD for token WETH
    dataFeedsUSD[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // CHAINLINK FEED KNC / USD for token KNC
    dataFeedsUSD[0xdd974D5C2e2928deA5F71b9825b8b646686BD200] = 0xf8fF43E991A81e6eC886a3D281A2C6cC19aE70Fc;

    // CHAINLINK FEED LINK / USD for token LINK
    dataFeedsUSD[0x514910771AF9Ca656af840dff83E8264EcF986CA] = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c;

    // CHAINLINK FEED LRC / ETH for token LRC
    dataFeedsETH[0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD] = 0x160AC928A16C93eD4895C2De6f81ECcE9a7eB7b4;

    // CHAINLINK FEED MANA / USD for token MANA
    dataFeedsUSD[0x0F5D2fB29fb7d3CFeE444a200298f468908cC942] = 0x56a4857acbcfe3a66965c251628B1c9f1c408C19;

    // CHAINLINK FEED USDP / USD for token USDP
    dataFeedsUSD[0x8E870D67F660D95d5be530380D0eC0bd388289E1] = 0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3;

    // CHAINLINK FEED TUSD / USD for token TUSD
    dataFeedsUSD[0x0000000000085d4780B73119b644AE5ecd22b376] = 0xec746eCF986E2927Abd291a2A1716c940100f8Ba;

    // CHAINLINK FEED USDC / USD for token USDC
    dataFeedsUSD[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    // CHAINLINK FEED USDT / USD for token USDT
    dataFeedsUSD[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;

    // CHAINLINK FEED ZRX / USD for token ZRX
    dataFeedsUSD[0xE41d2489571d322189246DaFA5ebDe1F4699F498] = 0x2885d15b8Af22648b98B122b22FDF4D2a56c6023;

    // CHAINLINK FEED BAL / USD for token BAL
    dataFeedsUSD[0xba100000625a3754423978a60c9317c58a424e3D] = 0xdF2917806E30300537aEB49A7663062F4d1F2b5F;

    // CHAINLINK FEED YFI / USD for token YFI
    dataFeedsUSD[0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e] = 0xA027702dbb89fbd58938e4324ac03B58d812b0E1;

    // CHAINLINK FEED GUSD / USD for token GUSD
    dataFeedsUSD[0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd] = 0xa89f5d2365ce98B3cD68012b6f503ab1416245Fc;

    // CHAINLINK FEED UNI / USD for token UNI
    dataFeedsUSD[0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984] = 0x553303d460EE0afB37EdFf9bE42922D8FF63220e;

    // CHAINLINK FEED BTC / USD for token renBTC
    dataFeedsUSD[0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;

    // CHAINLINK FEED AAVE / USD for token AAVE
    dataFeedsUSD[0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9] = 0x547a514d5e3769680Ce22B2361c10Ea13619e8a9;

    // CHAINLINK FEED MATIC / USD for token MATIC
    dataFeedsUSD[0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0] = 0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676;

    // CHAINLINK FEED ETH / USD for token wstETH
    dataFeedsUSD[0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // CHAINLINK FEED ETH / USD for token rETH
    dataFeedsUSD[0xae78736Cd615f374D3085123A210448E74Fc6393] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // CHAINLINK FEED GNO / ETH for token GNO
    dataFeedsETH[0x6810e776880C02933D47DB1b9fc05908e5386b96] = 0xA614953dF476577E90dcf4e3428960e221EA4727;

    // CHAINLINK FEED wBTC / BTC for token WBTC
    dataFeedsBTC[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = 0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;
            
    // CHAINLINK FEED wBTC / BTC for token WBTC
    dataFeedsBTC[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = 0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;
            
    // CHAINLINK FEED wBTC / BTC for token WBTC
    dataFeedsBTC[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = 0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;

    regularMcdJoins = [
      0x3D0B1912B66114d4096F48A8CEe3A56C231772cA, // MCD_JOIN_BAT_A -> BAT
      0xBEa7cDfB4b49EC154Ae1c0D731E4DC773A3265aA, // MCD_JOIN_COMP_A -> COMP
      0x2F0b23f53734252Bda2277357e97e1517d6B042A, // MCD_JOIN_ETH_A -> WETH
      0x08638eF1A205bE6762A8b935F5da9b700Cf7322c, // MCD_JOIN_ETH_B -> WETH
      0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E, // MCD_JOIN_ETH_C -> WETH
      0x475F1a89C1ED844A08E8f6C50A00228b5E59E4A9, // MCD_JOIN_KNC_A -> KNC
      0xdFccAf8fDbD2F4805C174f856a317765B49E4a50, // MCD_JOIN_LINK_A -> LINK
      0x6C186404A7A238D3d6027C0299D1822c1cf5d8f1, // MCD_JOIN_LRC_A -> LRC
      0xA6EA3b9C04b8a38Ff5e224E7c3D6937ca44C0ef9, // MCD_JOIN_MANA_A -> MANA
      0x7e62B7E279DFC78DEB656E34D6a435cC08a44666, // MCD_JOIN_PAXUSD_A -> USDP
      0x4454aF7C8bb9463203b66C816220D41ED7837f44, // MCD_JOIN_TUSD_A -> TUSD
      0xA191e578a6736167326d05c119CE0c90849E84B7, // MCD_JOIN_USDC_A -> USDC
      0x2600004fd1585f7270756DDc88aD9cfA10dD0428, // MCD_JOIN_USDC_B -> USDC
      0x0A59649758aa4d66E25f08Dd01271e891fe52199, // MCD_JOIN_USDC_PSM_A -> USDC
      0x0Ac6A1D74E84C2dF9063bDDc31699FF2a2BB22A2, // MCD_JOIN_USDT_A -> USDT
      0xc7e8Cd72BDEe38865b4F5615956eF47ce1a7e5D0, // MCD_JOIN_ZRX_A -> ZRX
      0x4a03Aa7fb3973d8f0221B466EefB53D0aC195f55, // MCD_JOIN_BAL_A -> BAL
      0x3ff33d9162aD47660083D7DC4bC02Fb231c81677, // MCD_JOIN_YFI_A -> YFI
      0xe29A14bcDeA40d83675aa43B72dF07f649738C8b, // MCD_JOIN_GUSD_A -> GUSD
      0x79A0FA989fb7ADf1F8e80C93ee605Ebb94F7c6A5, // MCD_JOIN_GUSD_PSM_A -> GUSD
      0x3BC3A58b4FC1CbE7e98bB4aB7c99535e8bA9b8F1, // MCD_JOIN_UNI_A -> UNI
      0xFD5608515A47C37afbA68960c1916b79af9491D0, // MCD_JOIN_RENBTC_A -> renBTC
      0x24e459F61cEAa7b1cE70Dbaea938940A7c5aD46e, // MCD_JOIN_AAVE_A -> AAVE
      0x7bbd8cA5e413bCa521C2c80D8d1908616894Cf21, // MCD_JOIN_PAX_PSM_A -> USDP
      0x885f16e177d45fC9e7C87e1DA9fd47A9cfcE8E13, // MCD_JOIN_MATIC_A -> MATIC
      0x10CD5fbe1b404B7E19Ef964B63939907bdaf42E2, // MCD_JOIN_WSTETH_A -> wstETH
      0x248cCBf4864221fC0E840F29BB042ad5bFC89B5c, // MCD_JOIN_WSTETH_B -> wstETH
      0xC6424e862f1462281B0a5FAc078e4b63006bDEBF, // MCD_JOIN_RETH_A -> rETH
      0x7bD3f01e24E0f0838788bC8f573CEA43A80CaBB5, // MCD_JOIN_GNO_A -> GNO
      0xBF72Da2Bd84c5170618Fbe5914B0ECA9638d5eb5, // MCD_JOIN_WBTC_A -> WBTC
      0xfA8c996e158B80D77FbD0082BB437556A65B96E0, // MCD_JOIN_WBTC_B -> WBTC
      0x7f62f9592b823331E012D3c5DdF2A7714CfB9de2 // MCD_JOIN_WBTC_C -> WBTC
    ];

    univ2McdJoins = [
      0xDc26C9b7a8fe4F5dF648E314eC3E6Dc3694e6Dd2, // MCD_JOIN_UNIV2WBTCETH_A -> UNI-V2
      0x03Ae53B33FeeAc1222C3f372f32D37Ba95f0F099, // MCD_JOIN_UNIV2USDCETH_A -> UNI-V2
      0xA81598667AC561986b70ae11bBE2dd5348ed4327, // MCD_JOIN_UNIV2DAIUSDC_A -> UNI-V2
      0x4aAD139a88D2dd5e7410b408593208523a3a891d, // MCD_JOIN_UNIV2ETHUSDT_A -> UNI-V2
      0xDae88bDe1FB38cF39B6A02b595930A3449e593A6, // MCD_JOIN_UNIV2LINKETH_A -> UNI-V2
      0xf11a98339FE1CdE648e8D1463310CE3ccC3d7cC1, // MCD_JOIN_UNIV2UNIETH_A -> UNI-V2
      0xD40798267795Cbf3aeEA8E9F8DCbdBA9b5281fcC, // MCD_JOIN_UNIV2WBTCDAI_A -> UNI-V2
      0x42AFd448Df7d96291551f1eFE1A590101afB1DfF, // MCD_JOIN_UNIV2AAVEETH_A -> UNI-V2
      0xAf034D882169328CAf43b823a4083dABC7EEE0F4 // MCD_JOIN_UNIV2DAIUSDT_A -> UNI-V2
    ];

    guniv3McdJoins = [
      0xbFD445A97e7459b0eBb34cfbd3245750Dba4d7a4, // MCD_JOIN_GUNIV3DAIUSDC1_A -> G-UNI
      0xA7e4dDde3cBcEf122851A7C8F7A55f23c0Daf335 // MCD_JOIN_GUNIV3DAIUSDC2_A -> G-UNI
    ];

    testedContracts = [
      // MCD_JOIN_BAT_A
      0x3D0B1912B66114d4096F48A8CEe3A56C231772cA,
      // CHAINLINK FEED BAT / ETH
      0x0d16d4528239e9ee52fa531af613AcdB23D88c94,
      // MCD_JOIN_COMP_A
      0xBEa7cDfB4b49EC154Ae1c0D731E4DC773A3265aA,
      // CHAINLINK FEED COMP / USD
      0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5,
      // MCD_JOIN_ETH_A
      0x2F0b23f53734252Bda2277357e97e1517d6B042A,
      // CHAINLINK FEED ETH / USD
      0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
      // MCD_JOIN_ETH_B
      0x08638eF1A205bE6762A8b935F5da9b700Cf7322c,
      // MCD_JOIN_ETH_C
      0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E,
      // MCD_JOIN_KNC_A
      0x475F1a89C1ED844A08E8f6C50A00228b5E59E4A9,
      // CHAINLINK FEED KNC / USD
      0xf8fF43E991A81e6eC886a3D281A2C6cC19aE70Fc,
      // MCD_JOIN_LINK_A
      0xdFccAf8fDbD2F4805C174f856a317765B49E4a50,
      // CHAINLINK FEED LINK / USD
      0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c,
      // MCD_JOIN_LRC_A
      0x6C186404A7A238D3d6027C0299D1822c1cf5d8f1,
      // CHAINLINK FEED LRC / ETH
      0x160AC928A16C93eD4895C2De6f81ECcE9a7eB7b4,
      // MCD_JOIN_MANA_A
      0xA6EA3b9C04b8a38Ff5e224E7c3D6937ca44C0ef9,
      // CHAINLINK FEED MANA / USD
      0x56a4857acbcfe3a66965c251628B1c9f1c408C19,
      // MCD_JOIN_PAXUSD_A
      0x7e62B7E279DFC78DEB656E34D6a435cC08a44666,
      // CHAINLINK FEED USDP / USD
      0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3,
      // MCD_JOIN_TUSD_A
      0x4454aF7C8bb9463203b66C816220D41ED7837f44,
      // CHAINLINK FEED TUSD / USD
      0xec746eCF986E2927Abd291a2A1716c940100f8Ba,
      // MCD_JOIN_USDC_A
      0xA191e578a6736167326d05c119CE0c90849E84B7,
      // CHAINLINK FEED USDC / USD
      0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6,
      // MCD_JOIN_USDC_B
      0x2600004fd1585f7270756DDc88aD9cfA10dD0428,
      // MCD_JOIN_USDC_PSM_A
      0x0A59649758aa4d66E25f08Dd01271e891fe52199,
      // MCD_JOIN_USDT_A
      0x0Ac6A1D74E84C2dF9063bDDc31699FF2a2BB22A2,
      // CHAINLINK FEED USDT / USD
      0x3E7d1eAB13ad0104d2750B8863b489D65364e32D,
      // MCD_JOIN_ZRX_A
      0xc7e8Cd72BDEe38865b4F5615956eF47ce1a7e5D0,
      // CHAINLINK FEED ZRX / USD
      0x2885d15b8Af22648b98B122b22FDF4D2a56c6023,
      // MCD_JOIN_BAL_A
      0x4a03Aa7fb3973d8f0221B466EefB53D0aC195f55,
      // CHAINLINK FEED BAL / USD
      0xdF2917806E30300537aEB49A7663062F4d1F2b5F,
      // MCD_JOIN_YFI_A
      0x3ff33d9162aD47660083D7DC4bC02Fb231c81677,
      // CHAINLINK FEED YFI / USD
      0xA027702dbb89fbd58938e4324ac03B58d812b0E1,
      // MCD_JOIN_GUSD_A
      0xe29A14bcDeA40d83675aa43B72dF07f649738C8b,
      // CHAINLINK FEED GUSD / USD
      0xa89f5d2365ce98B3cD68012b6f503ab1416245Fc,
      // MCD_JOIN_GUSD_PSM_A
      0x79A0FA989fb7ADf1F8e80C93ee605Ebb94F7c6A5,
      // MCD_JOIN_UNI_A
      0x3BC3A58b4FC1CbE7e98bB4aB7c99535e8bA9b8F1,
      // CHAINLINK FEED UNI / USD
      0x553303d460EE0afB37EdFf9bE42922D8FF63220e,
      // MCD_JOIN_RENBTC_A
      0xFD5608515A47C37afbA68960c1916b79af9491D0,
      // CHAINLINK FEED BTC / USD
      0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c,
      // MCD_JOIN_AAVE_A
      0x24e459F61cEAa7b1cE70Dbaea938940A7c5aD46e,
      // CHAINLINK FEED AAVE / USD
      0x547a514d5e3769680Ce22B2361c10Ea13619e8a9,
      // MCD_JOIN_PAX_PSM_A
      0x7bbd8cA5e413bCa521C2c80D8d1908616894Cf21,
      // MCD_JOIN_MATIC_A
      0x885f16e177d45fC9e7C87e1DA9fd47A9cfcE8E13,
      // CHAINLINK FEED MATIC / USD
      0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676,
      // MCD_JOIN_WSTETH_A
      0x10CD5fbe1b404B7E19Ef964B63939907bdaf42E2,
      // MCD_JOIN_WSTETH_B
      0x248cCBf4864221fC0E840F29BB042ad5bFC89B5c,
      // MCD_JOIN_RETH_A
      0xC6424e862f1462281B0a5FAc078e4b63006bDEBF,
      // MCD_JOIN_GNO_A
      0x7bD3f01e24E0f0838788bC8f573CEA43A80CaBB5,
      // CHAINLINK FEED GNO / ETH
      0xA614953dF476577E90dcf4e3428960e221EA4727,
      // MCD_JOIN_WBTC_A
      0xBF72Da2Bd84c5170618Fbe5914B0ECA9638d5eb5,
      // CHAINLINK FEED wBTC / BTC
      0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23,
      // MCD_JOIN_WBTC_B
      0xfA8c996e158B80D77FbD0082BB437556A65B96E0,
      // MCD_JOIN_WBTC_C
      0x7f62f9592b823331E012D3c5DdF2A7714CfB9de2,
      // MCD_JOIN_UNIV2WBTCETH_A
      0xDc26C9b7a8fe4F5dF648E314eC3E6Dc3694e6Dd2,
      // MCD_JOIN_UNIV2USDCETH_A
      0x03Ae53B33FeeAc1222C3f372f32D37Ba95f0F099,
      // MCD_JOIN_UNIV2DAIUSDC_A
      0xA81598667AC561986b70ae11bBE2dd5348ed4327,
      // MCD_JOIN_UNIV2ETHUSDT_A
      0x4aAD139a88D2dd5e7410b408593208523a3a891d,
      // MCD_JOIN_UNIV2LINKETH_A
      0xDae88bDe1FB38cF39B6A02b595930A3449e593A6,
      // MCD_JOIN_UNIV2UNIETH_A
      0xf11a98339FE1CdE648e8D1463310CE3ccC3d7cC1,
      // MCD_JOIN_UNIV2WBTCDAI_A
      0xD40798267795Cbf3aeEA8E9F8DCbdBA9b5281fcC,
      // MCD_JOIN_UNIV2AAVEETH_A
      0x42AFd448Df7d96291551f1eFE1A590101afB1DfF,
      // MCD_JOIN_UNIV2DAIUSDT_A
      0xAf034D882169328CAf43b823a4083dABC7EEE0F4,
      // MCD_JOIN_GUNIV3DAIUSDC1_A
      0xbFD445A97e7459b0eBb34cfbd3245750Dba4d7a4,
      // MCD_JOIN_GUNIV3DAIUSDC2_A
      0xA7e4dDde3cBcEf122851A7C8F7A55f23c0Daf335,
      // CHAINLINK FEED BTC / USD 
      0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c
    ];

    initialTVL = getCurrentTVL();
    thresholdTVL = (100 - _thresholdPercentage) * initialTVL / 100;
  }


  /// @notice test to check if TVL value of MakerDAO has decreased by %X since test deployment
  /// @return true if TVL value of MakerDAO has not decreased by %X since test deployment
  function checkTestPasses() public view override returns (bool) {
    
    return (getCurrentTVL() >= thresholdTVL);
  }

  /// @notice get TVL value of MakerDAO
  /// @return TVL value of MakerDAO
  function getCurrentTVL() public view returns (uint256) {
    uint256 regularMcdJoinsValue = getRegularMcdJoinsValue();
    //uint256 wbtcMcdJoinsValue = getWbtcMcdJoinsValue();
    uint256 univ2McdJoinsValue = getUniv2McdJoinsValue();
    uint256 guniv3McdJoinsValue = getGuniv3McdJoinsValue();
    return regularMcdJoinsValue 
    + univ2McdJoinsValue 
    + guniv3McdJoinsValue;
  }

  function getRegularMcdJoinsValue() public view returns (uint256) {
    uint256 total = 0;
    for(uint256 i = 0; i < regularMcdJoins.length; i++) {
      total = total + getRegularJoinValue(regularMcdJoins[i]);
      
    }
    return total;
  }

  function getUniv2McdJoinsValue() public view returns (uint256) {
    uint256 total = 0;
    for(uint256 i = 0; i < univ2McdJoins.length; i++) {
      total = total + getUniv2JoinValue(univ2McdJoins[i]);
    }
    return total;
  }

  function getGuniv3McdJoinsValue() public view returns (uint256) {
    uint256 total = 0;
    for(uint256 i = 0; i < guniv3McdJoins.length; i++) {
      total = total + getGuniv3JoinValue(guniv3McdJoins[i]);
    }
    return total;
  }
  
  function getUniv2JoinValue(address _join) public view returns (uint256) {
    IUniswapV2Pair pair = IUniswapV2Pair(IGemJoin(_join).gem());
    address token0 = pair.token0();
    address token1 = pair.token1();
    uint256 pairAmount = pair.balanceOf(_join);
    (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
    uint256 totalSupply = pair.totalSupply();
    uint256 total = 0;
    if(token0 != DAI){
      uint256 token0Amount = pairAmount * reserve0 / totalSupply;
      total = total + getUsdValue(token0, token0Amount);
    }
    if(token1 != DAI){
      uint256 token1Amount = pairAmount * reserve1 / totalSupply;
      total = total + getUsdValue(token1, token1Amount);
    }
    return total;
  }

  function getGuniv3JoinValue(address _join) public view returns (uint256) {
    IGUniV3Pair pair = IGUniV3Pair(IGemJoin(_join).gem());
    address token0 = pair.token0();
    address token1 = pair.token1();
    uint256 pairAmount = pair.balanceOf(_join);
    (uint256 reserve0, uint256 reserve1 ) = pair.getUnderlyingBalances();
    uint256 totalSupply = pair.totalSupply();
    uint256 total = 0;
    
    if(token0 != DAI){
      uint256 token0Amount = pairAmount * reserve0 / totalSupply;
      total = total + getUsdValue(token0, token0Amount);
    }
    if(token1 != DAI){
      uint256 token1Amount = pairAmount * reserve1 / totalSupply;
      total = total + getUsdValue(token1, token1Amount);
    }
    return total;
  }

  function getRegularJoinValue(address _join) public view returns (uint256) {
    return getUsdValue(IGemJoin(_join).gem(), _join);
  }

  function getUsdValue(address _token, address account) public view returns (uint256) {

    IERC20Metadata token = IERC20Metadata(_token);
    uint256 amount;
    if(address(token) == RENBTC){
      amount = IRenBTC(address(token)).balanceOfUnderlying(account);
    } else if(address(token) == RETH) {
      uint256 rethAmount = token.balanceOf(account);
      amount = IRETH(RETH).getEthValue(rethAmount);
    } else if(address(token) == WSTETH) {
      uint256 wstethAmount = token.balanceOf(account);
      uint256 amountStETH = IWSTETH(WSTETH).getStETHByWstETH(wstethAmount);
      IStETH steth = IStETH(IWSTETH(WSTETH).stETH());
      amount = steth.getPooledEthByShares(amountStETH);
    } else {
      amount = token.balanceOf(account);
    }
    
    return getUsdValue(_token, amount);

  }

  function getUsdValue(address _token, uint256 amount) public view returns(uint256){
    IERC20Metadata token = IERC20Metadata(_token);
    uint256 decimals = token.decimals();
    if(dataFeedsUSD[address(token)] != address(0)){
      uint256 price = uint256(IChainlinkAggregator(dataFeedsUSD[address(token)]).latestAnswer());
      return calculateValue(amount, price, decimals);
    }
    if(dataFeedsETH[address(token)] != address(0)){
      uint256 priceInETH = uint256(IChainlinkAggregator(dataFeedsETH[address(token)]).latestAnswer());
      uint256 valueInETH = calculateValue(amount, priceInETH, decimals);
      uint256 priceOfETH = uint256(IChainlinkAggregator(dataFeedsUSD[WETH]).latestAnswer());
      return calculateValue(valueInETH, priceOfETH, 18);
    }
    if(dataFeedsBTC[address(token)] != address(0)){
      uint256 priceInBTC = uint256(IChainlinkAggregator(dataFeedsBTC[address(token)]).latestAnswer());
      uint256 valueInBTC = calculateValue(amount, priceInBTC, 8);
      uint256 priceOfBTC = uint256(IChainlinkAggregator(btcToUsdDataFeed).latestAnswer());
      return calculateValue(valueInBTC, priceOfBTC, 8);
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
