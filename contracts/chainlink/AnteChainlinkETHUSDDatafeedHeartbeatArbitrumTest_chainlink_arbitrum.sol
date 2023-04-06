// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed for ETH/USD heartbeat is respected on Arbitrum
// @notice Ensure that Chainlink data feed ETH/USD update according to declared at least once per day heartbeat
contract AnteChainlinkETHUSDDatafeedHeartbeatArbitrumTest is
    AnteTest("Ensure that Chainlink data feed ETH/USD update according to declared at least once per day heartbeat")
{
    
    // datafeed ETH/USD on Arbitrum
    AggregatorInterface constant datafeed = AggregatorInterface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612);
    
    uint256 constant declaredHeartbeat = 86400;
    
    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        ];
    }

    function checkTestPasses() public view override returns (bool) {
        
        uint256 updatedAt = datafeed.latestTimestamp();
        if (updatedAt + declaredHeartbeat + 60 < block.timestamp) {
            return false;
        }
        return true;
    }
}
