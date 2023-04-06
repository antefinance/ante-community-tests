// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed for LINK/USD heartbeat is respected on Arbitrum
// @notice Ensure that Chainlink data feed LINK/USD update according to declared at least once per hour heartbeat
contract AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest is
    AnteTest("Ensure that Chainlink data feed LINK/USD update according to declared at least once per hour heartbeat")
{
    
    // datafeed LINK/USD on Arbitrum
    AggregatorInterface constant datafeed = AggregatorInterface(0x86E53CF1B870786351Da77A57575e79CB55812CB);
    
    uint256 constant declaredHeartbeat = 3600;
    
    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x86E53CF1B870786351Da77A57575e79CB55812CB
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
