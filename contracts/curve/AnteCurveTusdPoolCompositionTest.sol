// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Curve tusd Pool Composition Test
/// @notice Checks that the TUSD balance, and the DAI, USDC, USDT balances in Curve 3Pool scaled by 
///         the amount of 3CRV in Curve tusd, are each < 90% of Curve tusd pool's total token balance.
contract AnteCurveTusdPoolCompositionTest is AnteTest("TUSD, DAI, USDC, USDT balances are each < 90% of Curve tusd pool balance") {
    address public constant CURVE_TUSD_POOL_ADDRESS = 0xEcd5e75AFb02eFa118AF914515D6521aaBd189F1;
    address public constant CURVE_3POOL_POOL_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address public constant CURVE_3CRV_ADDRESS = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address public constant TUSD_ADDRESS = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20Metadata private constant TUSD = IERC20Metadata(TUSD_ADDRESS);
    IERC20Metadata private constant CURVE_3CRV = IERC20Metadata(CURVE_3CRV_ADDRESS);
    IERC20Metadata private constant DAI = IERC20Metadata(DAI_ADDRESS);
    IERC20Metadata private constant USDC = IERC20Metadata(USDC_ADDRESS);
    IERC20Metadata private constant USDT = IERC20Metadata(USDT_ADDRESS);

    constructor() {
        testedContracts = [CURVE_TUSD_POOL_ADDRESS];
        protocolName = "Curve";
    }

    /// @return true if the balances of each token are < 90%
    function checkTestPasses() public view override returns (bool) {
        uint256 TUSDBalance = TUSD.balanceOf(CURVE_TUSD_POOL_ADDRESS) / 10**TUSD.decimals();
        uint256 DAIBalance = DAI.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**DAI.decimals();
        uint256 USDCBalance = USDC.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDC.decimals();
        uint256 USDTBalance = USDT.balanceOf(CURVE_3POOL_POOL_ADDRESS) / 10**USDT.decimals();
        uint256 CURVE_3CRV_SCALING_FACTOR = CURVE_3CRV.balanceOf(CURVE_TUSD_POOL_ADDRESS) * 1000 / CURVE_3CRV.totalSupply();

        return isLessThanNinety(
            TUSDBalance,
            DAIBalance * CURVE_3CRV_SCALING_FACTOR / 1000,
            USDCBalance * CURVE_3CRV_SCALING_FACTOR / 1000,
            USDTBalance * CURVE_3CRV_SCALING_FACTOR / 1000
        );
    }

    /// @dev Function used for unit testing to ensure the input and output is correct
    /// @param tusd The amount of TUSD in the pool
    /// @param dai The amount of DAI in the pool
    /// @param usdc The amount of USDC in the pool
    /// @param usdt The amount of USDT in the pool
    /// @return true if tusd, dai, usdc, usdt are each < 90% of their sum.
    function isLessThanNinety(
            uint256 tusd,
            uint256 dai,
            uint256 usdc,
            uint256 usdt
        ) public pure returns (bool) {
            uint256 totalSupply = tusd + dai + usdc + usdt;
            uint256 multiplier = 100;
            uint256 threshold = 90;
            uint256 tusdPercent = tusd * multiplier / totalSupply;
            uint256 daiPercent = dai * multiplier / totalSupply;
            uint256 usdcPercent = usdc * multiplier / totalSupply;
            uint256 usdtPercent = usdt * multiplier / totalSupply;

        return (
            tusdPercent < threshold &&
            daiPercent < threshold &&
            usdcPercent < threshold &&
            usdtPercent < threshold
        );
    }
    function getTUSDBalance() public view returns (uint256) {
        return TUSD.balanceOf(CURVE_TUSD_POOL_ADDRESS) / 10**TUSD.decimals();
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
        return CURVE_3CRV.balanceOf(CURVE_TUSD_POOL_ADDRESS) * 1000 / CURVE_3CRV.totalSupply();
    }
}
