// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Aevo L1 Bridge doesn't plunge by X% within a fixed time window
/// @notice Ante Test to check if Aevo L1 Bridge token balances drop by 95% in a 72-hour window
contract AevoL1BridgePlungeRateTest is AnteTest("Aevo L1 Bridge top token balances don't drop by 95% in 72 hours") {
    /// @notice minimum period after checkpointing before checkTestPasses call
    /// is allowed to fail
    uint32 public constant MIN_CHECKPOINT_AGE = 12 hours;
    /// @notice maximum period after checkpointing in which the test can fail
    uint32 public constant MAX_CHECKPOINT_AGE = 72 hours;

    /// @notice minimum interval between allowing subsequent checkpoints
    /// @dev prevents malicious stakers from preventing a failing test by calling checkpoint() repeatedly
    uint32 public constant MIN_CHECKPOINT_INTERVAL = 48 hours;

    uint32 private constant PERCENT_DROP_THRESHOLD = 95;

    // https://etherscan.io/address/0x4082C9647c098a6493fb499EaE63b5ce3259c574
    address public constant aevoL1BridgeAddr = 0x4082C9647c098a6493fb499EaE63b5ce3259c574;

    // Top 1 tokens
    IERC20[1] public tokens = [
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) //USDC
    ];

    uint256 public etherThreshold;

    /// @notice last time a checkpoint was taken
    uint256 public lastCheckpointTime;

    /// @notice threshold amounts below which the test fails
    uint256[1] public thresholds;

    constructor() {
        protocolName = "Aevo Bridge";
        testedContracts = [aevoL1BridgeAddr];

        _updateThresholds();
    }

    function _updateThresholds() private {
        lastCheckpointTime = block.timestamp;
        etherThreshold = (aevoL1BridgeAddr.balance * (100 - PERCENT_DROP_THRESHOLD)) / 100;
        for (uint256 i = 0; i < tokens.length; i++) {
            thresholds[i] = (tokens[i].balanceOf(aevoL1BridgeAddr) * (100 - PERCENT_DROP_THRESHOLD)) / 100;
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

    /// @notice test to check value of top 1 asset on Aevo Bridge hasn't dropped below a certain threshold
    /// in a given time window
    /// @return true if the top assets haven't dropped PERCENT_DROP_THRESHOLD since the last checkpoint
    /// or if the last checkpoint isn't in the allowed time interval window
    function checkTestPasses() public view override returns (bool) {
        uint256 timeSinceLastCheckpoint = block.timestamp - lastCheckpointTime;
        if (timeSinceLastCheckpoint > MIN_CHECKPOINT_AGE && timeSinceLastCheckpoint < MAX_CHECKPOINT_AGE) {
            if (aevoL1BridgeAddr.balance < etherThreshold) {
                return false;
            }
            for (uint256 i = 0; i < tokens.length; i++) {
                if (tokens[i].balanceOf(aevoL1BridgeAddr) < thresholds[i]) {
                    return false;
                }
            }
        }
        return true;
    }
}
