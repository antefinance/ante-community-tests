// SPDX-License-Identifier: MIT

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Chainlink feed for ETH/USD update at least once per day
contract AnteChainlinkETHUSDDatafeedUpdateDailyTest is AnteTest("Chainlink datafeed for ETH/USD update at least once per day") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0x13e3Ee699D1909E989722E753853AE30b17e08c5);

    uint256 private constant ONE_DAY = 86400;

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x13e3Ee699D1909E989722E753853AE30b17e08c5
        ];
        
    }

    /// @return true if the datafeed has been updated in the past day
    function checkTestPasses() external view override returns (bool) {
        uint256 currentTimeStamp = block.timestamp;
        uint256 lastUpdate = 0;

        (, , , lastUpdate, ) = datafeed.latestRoundData();
        if (currentTimeStamp - lastUpdate > ONE_DAY) {
            return false;
        }    

        return true;
    }
}
