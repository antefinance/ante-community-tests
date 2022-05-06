// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Synthetix USD Peg Test
/// @notice Ensures SUSD is pegged to USD +/- 2%
contract AnteSUSDPegTest is AnteTest("SUSD is pegged to USD") {
    AggregatorV3Interface internal priceFeed;

    int256 private preCheckPrice = 0;
    uint private preCheckBlock = 0;

    constructor() {
        protocolName = "Synthetix";
        testedContracts = [0x6B175474E89094C44Da98b954EedeAC495271d0F];
        priceFeed = AggregatorV3Interface(0xad35Bd71b9aFE6e4bDc266B345c198eaDEf9Ad94);
    }

    /// @notice Must be called 300-400 blocks (1hr) blocks before calling checkTestPasses to prevent flash loan attacks
    /// @notice Chainlink datafeeds trigger on a 1% difference. A flash loan attack will allow an asset to recover
    /// @notice within 1 hour.
    /// @dev Can only be called once 800 blocks to prevent spam reloading
    function preCheck() public {
        require (block.number - preCheckBlock > 800, "Precheck can only be called every 800 blocks");
        (, preCheckPrice, , , ) = priceFeed.latestRoundData();
        preCheckBlock = block.number;
    }

    /// @return true if the test will work properly (ie preCheck() was called 300-400 block prior)
    function willTestWork() public view returns(bool) {
        if (preCheckPrice == 0 || preCheckBlock == 0) return false;
        if ( !( 400 >= block.number - preCheckBlock && 300 <= block.number - preCheckBlock) ) return false;
        return true;
    }

    /// @notice Must call preCheck() 300-400 blocks prior to calling
    /// @return true the SUSD is pegged to USD +/- 2%
    function checkTestPasses() public view override returns (bool) {
        if (preCheckPrice == 0 || preCheckBlock == 0) return true;

        if ( !( 400 >= block.number - preCheckBlock && 300 <= block.number - preCheckBlock) ) return true;

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (98000000 < price && price < 102000000) || (98000000 < preCheckPrice && preCheckPrice < 102000000);
    }
}
