// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";

/// @notice Interface to interface with totalSurplus in the BalanceSheetModule
interface IBalanceSheetModule {
    function totalSurplus() external view returns (int256);
}

/// @title AnteYamaSurplusTest
/// @author jseam.eth
/// @notice Check if the surplus value of Yama Finance is greater than 0, other protocol has bad debt
///         Chains: Arbitrum
contract AnteYamaSurplusTest is AnteTest("Yama BSM Surplus >= 0") {
    // Balance Sheet Module on Yama that contains the surplus value of the protocol
    IBalanceSheetModule bsm = IBalanceSheetModule(0xB84D0EB7974825316fAea10ca9BFAa3D393C0a53);
    
    constructor() {
        protocolName = "Yama Finance";
        testedContracts = [0xB84D0EB7974825316fAea10ca9BFAa3D393C0a53];
    }

    /// @notice Checks if the Yama Finance protocol has no bad debt
    /// @return bool where totalSurplus >= 0
    function checkTestPasses() public view override returns (bool) {
        return bsm.totalSurplus() >= 0;
    }
}