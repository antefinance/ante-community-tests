// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓     ┏┓         ┏━━━┓
// ┃┏━┓┃    ┏┛┗┓        ┃┏━━┛
// ┃┗━┛┃┏━┓ ┗┓┏┛┏━━┓    ┃┗━━┓┏┓┏━┓ ┏━━┓ ┏━┓ ┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓ ┃┃ ┃┏┓┃    ┃┏━━┛┣┫┃┏┓┓┗━┓┃ ┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃ ┃┗┓┃┃━┫ ┏┓ ┃┃   ┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛ ┗━┛┗━━┛ ┗┛ ┗┛   ┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title  UST price remains within 5% of 1 USD
/// @notice Ante Test to check that the price of UST doesn't deviate by more than 5% from its USD peg
contract AnteUSTPegTest is AnteTest("UST price remains within 5% of 1 USD") {
    // https://etherscan.io/token/0xa47c8bf37f92aBed4A126BDA807A7b7498661acD
    address public constant UST_ADDRESS = 0xa47c8bf37f92aBed4A126BDA807A7b7498661acD;

    AggregatorV3Interface internal priceFeed;

    constructor() {
        // Chainlink UST/USD price feed on Ethereum Mainnet
        // https://etherscan.io/address/0x8b6d9085f310396C6E4f0012783E9f850eaa8a82
        priceFeed = AggregatorV3Interface(0x8b6d9085f310396C6E4f0012783E9f850eaa8a82);

        protocolName = "UST";
        testedContracts = [UST_ADDRESS];
    }

    /// @notice Checks price of UST relative to USD
    /// @return true if escrow wallet has greater than or equal to 22M USDC+USDT
    function checkTestPasses() external view override returns (bool) {
        // grab latest price from Chainlink feed
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // assuming decimals() will never be large enough for overflow to be an issue
        return
            (price > (int256(10**priceFeed.decimals()) * 95) / 100) &&
            (price < (int256(10**priceFeed.decimals()) * 105) / 100);
    }
}
