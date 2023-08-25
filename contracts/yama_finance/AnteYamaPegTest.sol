// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGLPManager} from "./IGLPManager.sol";

/// @title AnteYamaPegTest
/// @author jseam.eth
/// @notice Check if the underling peg price in GLP token prices stays within 10% range of $1
///         Chains: Arbitrum
contract AnteYamaPegTest is AnteTest("GLP Price stays within 10% of $1") {
    // Test the GLP Manager getPrice function
    // The getPrice should return ~$1 in general
    IGLPManager public constant GLPManager = IGLPManager(0x3963FfC9dff443c2A94f21b129D429891E32ec18);
    
    // GLP 1$, there's 12 decimal and 18 decimals
    // so 10% of 1_000_000_000_000 * 1e18 = 900_000_000_000 * 1e18
    uint256 public constant PriceThresholdBelowTenPerc = 900_000_000_000 * 1e18;
    uint256 public constant PriceThresholdAboveTenPerc = 1_100_000_000_000 * 1e18;
    address public constant MooGLPPriceAddr = 0x9110B1A15d7c80E2b6d0Ace2C6FD1B52748DA1E5;

    constructor() {
        protocolName = "Yama Finance";
        testedContracts = [MooGLPPriceAddr];
    }

    /// @notice Checks if GLP price doesn't go below 10% of $1
    /// @return Price of GLP > 90% of 1$
    function checkTestPasses() public view override returns (bool) {
        return GLPManager.getPrice(false) > PriceThresholdBelowTenPerc;
    }
}