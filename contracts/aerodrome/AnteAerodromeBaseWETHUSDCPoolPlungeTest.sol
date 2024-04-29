// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AnteTest } from "../AnteTest.sol";
import { IERC20 } from "../interfaces/IERC20.sol";

// @title Checks Aerodrome's WETH/USDC pool's TVL
// @notice Ensure that Aerodrome's Base WETH/USDC pool doesn't drop below 15% of its TVL
contract AnteAerodromeBaseWETHUSDCPoolPlungeTest is AnteTest("Checks Aerodrome's Base WETH/USDC pool maintains above 15% of deployed threshold") {

    // https://basescan.org/address/0xcDAC0d6c6C59727a65F871236188350531885C43
    address private constant WETHUSDC_POOL_ADDRESS = 0xcDAC0d6c6C59727a65F871236188350531885C43;

    IERC20 public wethToken = IERC20(0x4200000000000000000000000000000000000006);
    IERC20 public usdcToken = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);

    uint256 private constant PERCENT_DROP_THRESHOLD = 15;

    uint256 private immutable deployedBalanceWeth;
    uint256 private immutable deployedBalanceUsdc;


    constructor() {
        protocolName = "Aerodrome";
        testedContracts = [WETHUSDC_POOL_ADDRESS];

        deployedBalanceWeth = wethToken.balanceOf(WETHUSDC_POOL_ADDRESS);
        deployedBalanceUsdc = usdcToken.balanceOf(WETHUSDC_POOL_ADDRESS);
    }

    function checkTestPasses() public view override returns (bool) {
        return (
            wethToken.balanceOf(WETHUSDC_POOL_ADDRESS) > deployedBalanceWeth * PERCENT_DROP_THRESHOLD / 100 ||
            usdcToken.balanceOf(WETHUSDC_POOL_ADDRESS) > deployedBalanceUsdc * PERCENT_DROP_THRESHOLD / 100
        );
    }
}
