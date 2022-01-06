// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Ante Test to check USDC remains > 0.90
contract AnteUSDCPegTest is AnteTest("USDC is above 90 cents on the dollar") {
    // https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
    address public constant CircleUsdcAddr = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: USDC/USD
     * Address: 0x8fffffd4afb6115b954bd326cbe7b4ba576818f6
     */
    constructor() {
        protocolName = "USDC";
        testedContracts = [CircleUsdcAddr];
        priceFeed = AggregatorV3Interface(0x8fffffd4afb6115b954bd326cbe7b4ba576818f6);
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (90000000 < price);
    }
}
