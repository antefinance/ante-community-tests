// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title Stargate TVL Plunge Test
// @notice USDC and USDT are almost identical. APY may vary but should remain about the same.
// @notice resulting in TVL differences not being extremely different.
// @notice If TVL of USDC is 10x greater than USDT. Something is not right.
contract StargateYieldFarmDifference is AnteTest("Stargate yield farms have a TVL difference of < 90%") {
    address constant USDT_STARGATE = 0x38EA452219524Bb87e18dE1C24D3bB59510BD783;
    address constant USDC_STARGATE = 0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56;

    IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    constructor() {
        testedContracts = [USDT_STARGATE, USDC_STARGATE];
        protocolName = "Stargate";
    }

    // @return the current tvl
    function getBalances() public view returns (uint256, uint256) {
        uint256 x = USDT.balanceOf(USDT_STARGATE);
        uint256 y = USDC.balanceOf(USDC_STARGATE);

        // y should always be larger than x
        if (y < x) {
            (x, y) = (y, x);
        }
        return (x, y);
    }

    // @return if the larger pool is less than 10x larger than the smaller pool
    function checkTestPasses() public view override returns (bool) {
        (uint256 x, uint256 y) = getBalances();
        return (y / x < 10);
    }
}
