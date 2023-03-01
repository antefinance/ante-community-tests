// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed heartbeat is respected
// @notice Ensure that Chainlink data feeds update according to declared heartbeats
contract AllNetworksAnteChainlinkHeartbeatTest is
    AnteTest("Ensure that Chainlink data feeds update according to declared heartbeats")
{
    // Price feeds with 24h heartbeat
    AggregatorInterface[] public priceFeeds24h;
    // Price feeds with 1h heartbeat
    AggregatorInterface[] public priceFeeds1h;
    
    constructor(address[] memory _priceFeeds24h, address[] memory _priceFeeds1h) {
        protocolName = "Chainlink";

        for (uint256 i = 0; i < _priceFeeds24h.length; i++) {
            priceFeeds24h.push(AggregatorInterface(_priceFeeds24h[i]));
            testedContracts.push(_priceFeeds24h[i]);
        }

        for (uint256 i = 0; i < _priceFeeds1h.length; i++) {
            priceFeeds1h.push(AggregatorInterface(_priceFeeds1h[i]));
            testedContracts.push(_priceFeeds1h[i]);
        }
    }

    function checkTestPasses() external view override returns (bool) {
        // Check pairs with 24h heartbeat
        for (uint256 i = 0; i < priceFeeds24h.length; i++) {
            uint256 updatedAt = priceFeeds24h[i].latestTimestamp();

            // Check if the price was updated in the last 24 hours + 1 minute
            // 1 minute represents an error margin to prevent miner manipulation
            // of block.timestamp
            if (updatedAt + 86400 + 60 < block.timestamp) {
                return false;
            }
        }

        // Check pairs with 1h heartbeat
        for (uint256 i = 0; i < priceFeeds1h.length; i++) {
            uint256 updatedAt = priceFeeds1h[i].latestTimestamp();
            // Check if the price was updated in the last 1 hour + 1 minute
            // 1 minute represents an error margin to prevent miner manipulation
            // of block.timestamp
            if (updatedAt + 3600 + 60 < block.timestamp) {
                return false;
            }
        }

        return true;
    }
}
