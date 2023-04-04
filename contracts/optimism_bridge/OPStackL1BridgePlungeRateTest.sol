// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title OP stack L1 Bridge doesn't plunge by X% within a fixed time window
/// @notice Ante Test to check if as OP stack L1 Bridge TVL drops by X% in a Y-hour window
contract OPStackL1BridgePlungeRateTest is AnteTest("OP Stack L1 Bridge TVL doesn't drop by 70% in 72 hours") {
    /// @notice minimum period after checkpointing before checkTestPasses call
    /// is allowed to fail
    uint32 public constant MIN_CHECKPOINT_AGE = 12 hours;
    /// @notice maximum period after checkpointing in which the test can fail
    uint32 public constant MAX_CHECKPOINT_AGE = 72 hours;

    /// @notice minimum interval between allowing subsequent checkpoints
    /// @dev prevents malicious stakers from preventing a failing test by calling checkpoint() repeatedly
    uint32 public constant MIN_CHECKPOINT_INTERVAL = 48 hours;

    uint32 private constant PERCENT_DROP_THRESHOLD = 70;

    // https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1
    address public optimismL1BridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;

    // Top 6 tokens
    IERC20[6] public tokens = [
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), //USDC
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7), //USDT
        IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), //WBTC
        IERC20(0x01BA67AAC7f75f647D94220Cc98FB30FCc5105Bf), //Lyra
        IERC20(0x865377367054516e17014CcdED1e7d814EDC9ce4), //Dola
        IERC20(0xae78736Cd615f374D3085123A210448E74Fc6393) //rETH
    ];

    uint256 public etherThreshold;

    /// @notice last time a checkpoint was taken
    uint256 public lastCheckpointTime;

    /// @notice threshold amounts below which the test fails
    uint256[6] public thresholds;

    constructor() {
        protocolName = "Optimism Bridge";
        testedContracts = [optimismL1BridgeAddr];

        _updateThresholds();
    }

    function _updateThresholds() private {
        lastCheckpointTime = block.timestamp;
        etherThreshold = (optimismL1BridgeAddr.balance * (100 - PERCENT_DROP_THRESHOLD)) / 100;
        for (uint256 i = 0; i < tokens.length; i++) {
            thresholds[i] = (tokens[i].balanceOf(optimismL1BridgeAddr) * (100 - PERCENT_DROP_THRESHOLD)) / 100;
        }
    }

    /// @notice take checkpoint of current bridge token balances
    function checkpoint() public {
        require(
            (block.timestamp - lastCheckpointTime) > MIN_CHECKPOINT_INTERVAL,
            "Cannot call checkpoint more than once every 48 hours"
        );

        _updateThresholds();
    }

    /// @notice test to check value of top 6 assets on Optimism Bridge hasn't dropped below a certain threshold
    /// in a given time window
    /// @return true if the top assets haven't dropped PERCENT_DROP_THRESHOLD since the last checkpoint
    /// or if the last checkpoint isn't in the allowed time interval window
    function checkTestPasses() public view override returns (bool) {
        uint256 timeSinceLastCheckpoint = block.timestamp - lastCheckpointTime;
        if (timeSinceLastCheckpoint > MIN_CHECKPOINT_AGE && timeSinceLastCheckpoint < MAX_CHECKPOINT_AGE) {
            if (optimismL1BridgeAddr.balance < etherThreshold) {
                return false;
            }
            for (uint256 i = 0; i < tokens.length; i++) {
                if (tokens[i].balanceOf(optimismL1BridgeAddr) < thresholds[i]) {
                    return false;
                }
            }
        }
        return true;
    }
}
