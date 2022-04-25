// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
    /// @return true if price of UST falls between $0.95 and $1.05 inclusive
    function checkTestPasses() external view override returns (bool) {
        // grab latest price from Chainlink feed (currently 0.3% deviation, 24h heartbeat)
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // Exclude negative prices so we can safely cast to uint
        if (price < 0) {
            return false;
        }

        // make result not dependent on decimals in price feed remaining constant (assumes never <2)
        uint256 scalingFactor = 10**priceFeed.decimals() / 100;

        return uint256(price) >= (95 * scalingFactor) && uint256(price) <= (105 * scalingFactor);
    }
}
