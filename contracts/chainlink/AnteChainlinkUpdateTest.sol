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

/// @title Chainlink feeds update at least once per day
contract AnteChainlinkUpdateTimeTest is AnteTest("Chainlink datafeeds update at least once per day") {
    address[] private datafeeds;
    AggregatorV3Interface[] private chainlink;

    uint256 private constant ONE_DAY = 86400;

    constructor(address[] memory _datafeeds) {
        protocolName = "Chainlink";
        testedContracts = _datafeeds;
        datafeeds = _datafeeds;

        for (uint16 i = 0; i < datafeeds.length; i++) {
            chainlink.push(AggregatorV3Interface(datafeeds[i]));
        }
    }

    /// @return true if the datafeed has been updated in the past day
    function checkTestPasses() external view override returns (bool) {
        uint256 currentTimeStamp = block.timestamp;
        uint256 lastUpdate = 0;

        for (uint16 i = 0; i < chainlink.length; i++) {
            (, , , lastUpdate, ) = chainlink[i].latestRoundData();
            if (currentTimeStamp - lastUpdate > ONE_DAY) {
                return false;
            }
        }

        return true;
    }
}
