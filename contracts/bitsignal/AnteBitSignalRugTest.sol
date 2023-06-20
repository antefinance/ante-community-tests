// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface BitSignal {
    function betInitiated() external view returns (bool);
    function startTimestamp() external view returns (uint256);
}

/// @title Checks BitSignal balance doesn't get drained before bet settles
/// @notice Ante Test to check that the USDC and WBTC balance of BitSignal
///         remains above 1 WBTC and 1M USDC
contract AnteBitSignalRugTest is AnteTest("BitSignal not drained before bet settled") {
    address public immutable bitSignal;

    ERC20 public constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 public constant WBTC = ERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);

    // these are hard-coded in BitSignal but not public so duplicating here
    uint256 public constant USDC_THRESHOLD = 1_000_000e6;
    uint256 public constant WBTC_THRESHOLD = 1e8;

    constructor(address _bitSignal) {
        bitSignal = _bitSignal;
        
        protocolName = "BitSignal";
        testedContracts = [_bitSignal];
    }

    /// @notice checks BitSignal balance not drained once the bet is initiated
    ///         and settlement date has not yet been reached.
    /// @return true if BitSignal USDC balance > 1M and WBTC balance > 1, the
    ///         bet has been initiated, and the settlement date has not been
    ///         reached, OR if the bet has not yet been initiated, OR if the 
    ///         settlement date has passed.
    function checkTestPasses() public view override returns (bool) {
        // if bet not initiated, test will not fail
        if (!BitSignal(bitSignal).betInitiated()) return true;
        // if after settlement date, OK for balances to be gone so return true
        if (block.timestamp >= BitSignal(bitSignal).startTimestamp() + 90 days) return true;
        return (
            USDC.balanceOf(bitSignal) >= USDC_THRESHOLD &&
            WBTC.balanceOf(bitSignal) >= WBTC_THRESHOLD
        );
    }
}
