// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title WBTC Peg Test
/// @notice Checks that WBTC is pegged to BTC +/- 2%
contract AnteWBTCPegTest is AnteTest("WBTC is pegged to BTC +- 2%") {
    AggregatorV3Interface internal priceFeed;

    int256 private preCheckPrice = 0;
    uint256 private preCheckBlock = 0;

    constructor() {
        protocolName = "WBTC";
        testedContracts = [0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599];
        priceFeed = AggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);
    }

    /// @notice Must be called 300-400 blocks (1hr) blocks before calling checkTestPasses to prevent flash loan attacks
    /// @notice Chainlink datafeeds trigger on a 1% difference. A flash loan attack will allow an asset to recover
    /// @notice within 1 hour.
    /// @dev Can only be called once 800 blocks to prevent spam reloading
    function preCheck() public {
        require(block.number - preCheckBlock > 800, "Precheck can only be called every 800 blocks");
        (, preCheckPrice, , , ) = priceFeed.latestRoundData();
        preCheckBlock = block.number;
    }

    /// @return true if the test will work properly (ie preCheck() was called 300 block prior)
    function willTestWork() public view returns (bool) {
        if (preCheckPrice == 0 || preCheckBlock == 0) return false;
        if (block.number - preCheckBlock < 300) return false;

        return true;
    }

    /// @notice Must call preCheck() 300 blocks prior to calling
    /// @return true the WBTC is pegged to BTC +/- 2%
    function checkTestPasses() public view override returns (bool) {
        if (preCheckPrice == 0 || preCheckBlock == 0) return true;
        if (block.number - preCheckBlock < 300) return true;

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (98000000 < price && price < 102000000) || (98000000 < preCheckPrice && preCheckPrice < 102000000);
    }
}