// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title  Stargate TVL Plunge Test (Polygon)
// @notice Ante Test to check that assets in Stargate pools on Polygon
//         (currently USDT, USDC) do not plunge by 90% from the time of test
//         deploy
contract AnteStargatePolygonTVLPlungeTest is AnteTest("Stargate TVL on Polygon does not plunge by 90%") {
    address constant STARGATE_USDT_POOL = 0x29e38769f23701A2e4A8Ef0492e19dA4604Be62c;
    address constant STARGATE_USDC_POOL = 0x1205f31718499dBf1fCa446663B532Ef87481fe1;

    IERC20 constant USDT = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    IERC20 constant USDC = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

    uint256 immutable tvlThreshold;

    constructor() {
        protocolName = "Stargate";
        testedContracts = [STARGATE_USDT_POOL, STARGATE_USDC_POOL];

        tvlThreshold = getCurrentBalances() / 10;
    }

    // @notice Get current pool balances
    // @return the sum of tested stablecoin pool balances
    function getCurrentBalances() public view returns (uint256) {
        return (USDT.balanceOf(STARGATE_USDT_POOL) + USDC.balanceOf(STARGATE_USDC_POOL));
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (getCurrentBalances() > tvlThreshold);
    }
}
