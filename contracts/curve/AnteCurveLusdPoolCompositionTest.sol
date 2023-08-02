// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Curve lusd Pool Composition Test
/// @notice Checks that the LUSD balance, and the DAI, USDC, USDT balances in Curve 3Pool scaled by 
///         the amount of 3CRV in Curve lusd, are each < 90% of Curve lusd pool's total token balance.
contract AnteCurveLusdPoolCompositionTest is AnteTest("LUSD, DAI, USDC, USDT balances are each < 90% of Curve lusd pool balance") {
    address public constant CURVE_LUSD_POOL_ADDRESS = 0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA;
    address public constant CURVE_3POOL_POOL_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address public constant CURVE_3CRV_ADDRESS = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address public constant LUSD_ADDRESS = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20Metadata private constant LUSD = IERC20Metadata(LUSD_ADDRESS);
    IERC20Metadata private constant CURVE_3CRV = IERC20Metadata(CURVE_3CRV_ADDRESS);
    IERC20Metadata private constant DAI = IERC20Metadata(DAI_ADDRESS);
    IERC20Metadata private constant USDC = IERC20Metadata(USDC_ADDRESS);
    IERC20Metadata private constant USDT = IERC20Metadata(USDT_ADDRESS);

    constructor() {
        testedContracts = [CURVE_LUSD_POOL_ADDRESS];
        protocolName = "Curve";
    }

    /// @return true if the balances of each token are < 90%
    function checkTestPasses() public view override returns (bool) {
        uint256 LUSDBalance_in_lusd = LUSD.balanceOf(CURVE_LUSD_POOL_ADDRESS) / 10**LUSD.decimals();
        uint256 DAIBalance_in_3Pool = DAI.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**DAI.decimals();
        uint256 USDCBalance_in_3Pool = USDC.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDC.decimals();
        uint256 USDTBalance_in_3Pool = USDT.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDT.decimals();
        uint256 CURVE_3CRV_SCALING_FACTOR = CURVE_3CRV.balanceOf(CURVE_LUSD_POOL_ADDRESS) * 1000 / CURVE_3CRV.totalSupply();

        return isLessThanNinety(
            LUSDBalance_in_lusd,
            DAIBalance_in_3Pool * CURVE_3CRV_SCALING_FACTOR / 1000,
            USDCBalance_in_3Pool * CURVE_3CRV_SCALING_FACTOR / 1000,
            USDTBalance_in_3Pool * CURVE_3CRV_SCALING_FACTOR / 1000
        );
    }

    /// @dev Function used for unit testing to ensure the input and output is correct
    /// @param lusd The amount of LUSD in the pool
    /// @param dai The amount of DAI in the pool
    /// @param usdc The amount of USDC in the pool
    /// @param usdt The amount of USDT in the pool
    /// @return true if lusd, dai, usdc, usdt are each < 90% of their sum.
    function isLessThanNinety(
            uint256 lusd,
            uint256 dai,
            uint256 usdc,
            uint256 usdt
        ) public pure returns (bool) {
            uint256 totalSupply = lusd + dai + usdc + usdt;
            uint256 multiplier = 100;
            uint256 threshold = 90;
            uint256 lusdPercent = lusd * multiplier / totalSupply;
            uint256 daiPercent = dai * multiplier / totalSupply;
            uint256 usdcPercent = usdc * multiplier / totalSupply;
            uint256 usdtPercent = usdt * multiplier / totalSupply;

        return (
            lusdPercent < threshold &&
            daiPercent < threshold &&
            usdcPercent < threshold &&
            usdtPercent < threshold
        );
    }
    function getLUSDBalance() public view returns (uint256) {
        return LUSD.balanceOf(CURVE_LUSD_POOL_ADDRESS) / 10**LUSD.decimals();
    }
    function get3CRVBalance() public view returns (uint256) {
        return CURVE_3CRV.balanceOf(CURVE_3CRV_ADDRESS) / 10**CURVE_3CRV.decimals();
    }
    function getScaledDAIBalance() public view returns (uint256) {
        return DAI.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**DAI.decimals() * get3CRVScalingFactor() / 1000;
    }
    function getScaledUSDCBalance() public view returns (uint256) {
        return USDC.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDC.decimals() * get3CRVScalingFactor() / 1000;
    }
    function getScaledUSDTBalance() public view returns (uint256) {
        return USDT.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDT.decimals() * get3CRVScalingFactor() / 1000;
    }
    function get3CRVScalingFactor() public view returns (uint256) {
        return CURVE_3CRV.balanceOf(CURVE_LUSD_POOL_ADDRESS) * 1000 / CURVE_3CRV.totalSupply();
    }
}
