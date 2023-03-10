// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed for ETH/USD heartbeat is respected on Optimism
// @notice Ensure that Chainlink data feed ETH/USD update according to declared at least once per hour heartbeat
contract AnteChainlinkETHUSDDatafeedHeartbeatTest is
    AnteTest("Ensure that Chainlink data feed ETH/USD update according to declared at least once per hour heartbeat")
{
    
    // datafeed ETH/USD on Optimism
    AggregatorInterface constant datafeed = AggregatorInterface(0x13e3Ee699D1909E989722E753853AE30b17e08c5);
    
    uint256 constant declaredHeartbeat = 3600;
    
    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x13e3Ee699D1909E989722E753853AE30b17e08c5
        ];
    }

    function checkTestPasses() external view override returns (bool) {
        
        uint256 updatedAt = datafeed.latestTimestamp();
        if (updatedAt + declaredHeartbeat + 60 < block.timestamp) {
            return false;
        }
        return true;
    }
}
