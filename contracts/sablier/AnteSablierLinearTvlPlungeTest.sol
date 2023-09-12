// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Ensure that USDC, DAI and WETH balances do not drop more than 90% from deploy time
/// @notice Uses AggregatorV3Interface to calculate WETH price
contract AnteSablierLinearTvlPlungeTest is
    AnteTest("Ensure that Sablier TVL of USDC, DAI and WETH does not drop more than 90%")
{
    address public constant LINEAR_LOCKUP_ADDR = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;

    IERC20 private constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 private constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    AggregatorV3Interface private ethPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    AggregatorV3Interface private usdcPriceFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    AggregatorV3Interface private daiPriceFeed = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);

    uint256 private constant PERCENT_DROP_THRESHOLD = 90;

    /// @dev Threshold amount under which the test fails
    uint256 public usdThreshold;

    constructor() {
        protocolName = "Sablier";
        testedContracts = [LINEAR_LOCKUP_ADDR];

        usdThreshold = (getCurrentTVL() * (100 - PERCENT_DROP_THRESHOLD)) / 100;
    }

    /// @return true current TVL is greater than threshold.
    function checkTestPasses() public view override returns (bool) {
        return getCurrentTVL() > usdThreshold;
    }

    /// @return current WETH balance (18 decimals)
    function getWETHBalance() public view returns (uint256) {
        return WETH.balanceOf(LINEAR_LOCKUP_ADDR);
    }

    /// @return current USDC balance (18 decimals)
    function getUSDCBalance() public view returns (uint256) {
        return USDC.balanceOf(LINEAR_LOCKUP_ADDR) * 10 ** 12;
    }

    /// @return current DAI balance (18 decimals)
    function getDAIBalance() public view returns (uint256) {
        return DAI.balanceOf(LINEAR_LOCKUP_ADDR);
    }

    /// @return tvl with 8 decimals precision
    function getCurrentTVL() public view returns (uint256) {
        // Grab latest price from Chainlink feed. All feeds are 8 decimals
        (, int256 ethToUsd, , , ) = ethPriceFeed.latestRoundData();
        (, int256 daiToUsd, , , ) = daiPriceFeed.latestRoundData();
        (, int256 usdcToUsd, , , ) = usdcPriceFeed.latestRoundData();

        return
            ((getWETHBalance() * uint256(ethToUsd)) / 10 ** 18) +
            ((getUSDCBalance() * uint256(usdcToUsd)) / 10 ** 18) +
            ((getDAIBalance() * uint256(daiToUsd)) / 10 ** 18);
    }
}
