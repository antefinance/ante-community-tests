// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";

/// @title AnteArbitrumPlungeTest
/// @notice Ante Test to check that ETH in Arbitrum bridge does NOT drop below 15K (as of March 2024)
contract AnteArbitrumPlungeTest is AnteTest("ETH in Arbitrum bridge does NOT drop below 7K") {
    // https://etherscan.io/address/0x8315177aB297bA92A06054cE80a67Ed4DBd7ed3a
    address public constant arbitrumbridgeaddr = 0x8315177aB297bA92A06054cE80a67Ed4DBd7ed3a;

    // 2024-03-01: Balance is ~1.5M ETH, so -99% is 15K ETH
    uint256 public constant RUG_THRESHOLD = 15 * 1000 * 1e18;

    constructor() {
        protocolName = "arbitrum";
        testedContracts = [arbitrumbridgeaddr];
    }

    /// @notice test to check balance of ETH in Arbitrum bridge
    /// @return true if ETH in Arbitrum bridge is above 15K
    function checkTestPasses() public view override returns (bool) {
        return arbitrumbridgeaddr.balance >= RUG_THRESHOLD;
    }
}
