// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

// @title Chainlink data feed heartbeat is respected
// @notice Ensure that Chainlink data feeds update according to declared heartbeats
contract AnteChainlinkHeartbeatTest is
    AnteTest("Ensure that Chainlink data feeds update according to declared heartbeats")
{
    // Price feeds with 24h heartbeat
    AggregatorInterface[3] internal priceFeeds24h = [
        AggregatorInterface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419), // ETH / USD
        AggregatorInterface(0x14e613AC84a31f709eadbdF89C6CC390fDc9540A), // BNB / USD
        AggregatorInterface(0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c) // LINK / USD
    ];

    // Price feeds with 1h heartbeat
    AggregatorInterface[3] internal priceFeeds1h = [
        AggregatorInterface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c), // BTC / USD
        AggregatorInterface(0xAc559F25B1619171CbC396a50854A3240b6A4e99), // ETH / BTC
        AggregatorInterface(0x547a514d5e3769680Ce22B2361c10Ea13619e8a9) // AAVE / USD
    ];

    constructor() {
        protocolName = "Chainlink";

        for (uint256 i = 0; i < 3; i++) {
            testedContracts.push(address(priceFeeds24h[i]));
        }

        for (uint256 i = 0; i < 3; i++) {
            testedContracts.push(address(priceFeeds1h[i]));
        }
    }

    function checkTestPasses() external view override returns (bool) {
        // Check pairs with 24h heartbeat
        for (uint256 i = 0; i < 3; i++) {
            uint256 updatedAt = priceFeeds24h[i].latestTimestamp();

            // Check if the price was updated in the last 24 hours + 1 minute
            // 1 minute represents an error margin to prevent miner manipulation
            // of block.timestamp
            if (updatedAt + 86400 + 60 < block.timestamp) {
                return false;
            }
        }

        // Check pairs with 1h heartbeat
        for (uint256 i = 0; i < 3; i++) {
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
