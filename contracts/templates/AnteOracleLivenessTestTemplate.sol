// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// ==INSTRUCTIONS==
// TODO 1. Replace all instances of [Pair], [Chain], and [Time Period] with
//         appropriate values (e.g., ETH/USD, Ethereum, 1hr)
// TODO 2. Rename this file in the form:
//         AnteChainlink[Pair][Chain]Feed[Time Period]HeartbeatTest.sol
// TODO 3. Update Chainlink feed address and liveness threshold (marked TODO)
// TODO 4. Clean up comments as needed and remove instructions

/// @title Checks that Chainlink [Pair] feed on [Chain] updates every [Time Period]
/// @author Put your ETH address here
/// @notice Ante Test to check
// TODO Replace contract name with filename of the test (minus .sol)
contract AnteOracleLivenessTestTemplate is
    AnteTest("Chainlink [Pair] Feed on [CHAIN] updated within last [TIME PERIOD]")
{
    AggregatorV3Interface internal priceFeed;

    // TODO update Chainlink feed address and block explorer link
    // Chainlink [Pair] price feed on [Chain]
    // https://etherscan.io/address/0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    address public constant CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // TODO replace 3600 with desired threshold in seconds
    uint256 public constant LIVENESS_THRESHOLD = 3600;

    constructor() {
        priceFeed = AggregatorV3Interface(CHAINLINK_FEED);

        protocolName = "Chainlink";
        testedContracts = [CHAINLINK_FEED];
    }

    /// @notice checks if Chainlink [Pair] feed on [Chain] has been updated
    ///         within the last [Time Period]
    /// @return true if block.timestamp is within [Time Period] of the last
    ///         round update from the Chainlink [Pair] feed
    function checkTestPasses() public view override returns (bool) {
        (, , , uint256 updatedAt, ) = priceFeed.latestRoundData();

        return (updatedAt + LIVENESS_THRESHOLD >= block.timestamp);
    }
}
