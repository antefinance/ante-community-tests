// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenDaiPegTest DAI Optimism
/// @notice Ante Test to check if DAI Optimism pegs between +- 5% of USD
contract AnteStableTokenDaiPegTest is AnteTest("DAI on Optimism is pegged to +- 5% of USD") {

    address public constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x8dBa75e83DA73cc766A7e5a0ee71F656BAb470d6);
    
    constructor() {
        protocolName = "DAI";
        testedContracts = [0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
