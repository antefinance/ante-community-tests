// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed for LINK/USD heartbeat is respected on Optimism
// @notice Ensure that Chainlink data feed LINK/USD update according to declared at least once per day heartbeat
contract AnteChainlinkLINKUSDDatafeedHeartbeatTest is
    AnteTest("Ensure that Chainlink data feed LINK/USD update according to declared at least once per day heartbeat")
{
    
    // datafeed LINK/USD on Optimism
    AggregatorInterface constant datafeed = AggregatorInterface(0xCc232dcFAAE6354cE191Bd574108c1aD03f86450);
    
    uint256 constant declaredHeartbeat = 86400;
    
    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0xCc232dcFAAE6354cE191Bd574108c1aD03f86450
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
