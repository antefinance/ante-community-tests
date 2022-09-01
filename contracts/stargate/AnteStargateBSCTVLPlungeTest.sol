// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title  Stargate TVL Plunge Test (Binance Smart Chain)
// @notice Ante Test to check that assets in Stargate pools on Binance Smart
//         Chain (currently USDT, BUSD) do not plunge by 90% from the time of
//         test deploy
contract AnteStargateBSCTVLPlungeTest is AnteTest("Stargate TVL on BSC does not plunge by 90%") {
    address constant STARGATE_USDT_POOL = 0x9aA83081AA06AF7208Dcc7A4cB72C94d057D2cda;
    address constant STARGATE_BUSD_POOL = 0x98a5737749490856b401DB5Dc27F522fC314A4e1;

    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 immutable tvlThreshold;

    constructor() {
        protocolName = "Stargate";
        testedContracts = [STARGATE_USDT_POOL, STARGATE_BUSD_POOL];

        tvlThreshold = getCurrentBalances() / 10;
    }

    // @notice Get current pool balances
    // @return the sum of tested stablecoin pool balances
    function getCurrentBalances() public view returns (uint256) {
        return (USDT.balanceOf(STARGATE_USDT_POOL) + BUSD.balanceOf(STARGATE_BUSD_POOL));
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (getCurrentBalances() > tvlThreshold);
    }
}
