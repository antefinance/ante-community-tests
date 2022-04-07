// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Ensure that the liquidity TVL of USDC/ETH and USDT/ETH does not have a difference greater than 10x
/// @notice Eg USDC/ETH TVL = 10 and USDT/ETH TVL = 20 passes
/// @notice Eg USDC/ETH TVL = 10 and USDT/ETH TVL = 101 fails
/// @notice Uses AggregatorV3Interface to calculate WETH price
contract AnteUniswapUSDCETHUSDTETHPoolTVLDifference is AnteTest("Make sure that TVL of USDC/ETH & USDT/ETH liquidity pools is not 10x or greater of the smaller pool") {

    address private constant ETH_USDT = 0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36;
    address private constant ETH_USDC = 0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8;

    ERC20 private constant USDT = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 private constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 private constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    AggregatorV3Interface private ethPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    constructor() {
        protocolName = "Uniswap";
        testedContracts = [ETH_USDT, ETH_USDC];
    }

    /// @notice sanity function for the unit tests
    /// @return all values that are used in the calculation of the liquidity TVL
    function getLiquidityRewards() public view returns (uint256, uint256, uint256, uint256, int256) {
        uint256 ethusdcUSDC = USDC.balanceOf(ETH_USDC);
        uint256 ethusdcWETH = WETH.balanceOf(ETH_USDC);

        uint256 ethusdtUSDT = USDT.balanceOf(ETH_USDT);
        uint256 ethusdtWETH = WETH.balanceOf(ETH_USDT);

        (, int256 signedethToUSD, , ,) = ethPriceFeed.latestRoundData();

        return(ethusdcUSDC, ethusdcWETH, ethusdtUSDT, ethusdtWETH, signedethToUSD);
    }

    /// @return bool if the price difference is >= 3%
    function checkTestPasses() public view override returns (bool) {

        (, int256 signedethToUSD, , ,) = ethPriceFeed.latestRoundData();
        uint256 ethToUSD = uint256(signedethToUSD);

        // ETH/USDC TVL
        uint256 ethusdcUSDC = USDC.balanceOf(ETH_USDC);
        uint256 ethusdcWETH = WETH.balanceOf(ETH_USDC) / (10 ** 12); // Make up for decimal difference

        uint256 ethusdcDollarValue = ethusdcUSDC + (ethusdcWETH * ethToUSD);

        // ETH/USDT TVL
        uint256 ethusdtUSDT = USDT.balanceOf(ETH_USDT);
        uint256 ethusdtWETH = WETH.balanceOf(ETH_USDT) / (10 ** 12); // Make up for decimal difference

        uint256 ethusdtDollarValue = ethusdtUSDT + (ethusdtWETH * ethToUSD);

        // Compare the two
        if (ethusdcDollarValue >= ethusdtDollarValue) {
            return(ethusdcDollarValue / ethusdcDollarValue <= 10);
        } else {
            return(ethusdtDollarValue / ethusdcDollarValue <= 10);
        }
    }
}