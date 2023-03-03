// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.7.0;

import "../libraries/ante-v05-core/AnteTest.sol";

/// @title AnteArbitrumPlungeTest
/// @notice Ante Test to check that ETH in Arbitrum bridge does NOT drop below 7K (as of Aug 2022)
contract AnteArbitrumPlungeTest is AnteTest("ETH in Arbitrum bridge does NOT drop below 7K") {
    // https://etherscan.io/address/0x011b6e24ffb0b5f5fcc564cf4183c5bbbc96d515
    address public constant arbitrumbridgeaddr = 0x011B6E24FfB0B5f5fCc564cf4183C5BBBc96D515;

    // 2022-08-18: Balance is ~715K ETH, so -99% is 7K ETH
    uint256 public constant RUG_THRESHOLD = 7 * 1000 * 1e18;

    constructor() {
        protocolName = "arbitrum";
        testedContracts = [arbitrumbridgeaddr];
    }

    /// @notice test to check balance of ETH in Arbitrum bridge
    /// @return true if ETH in Arbitrum bridge is above 7K
    function checkTestPasses() external view override returns (bool) {
        return arbitrumbridgeaddr.balance >= RUG_THRESHOLD;
    }
}
