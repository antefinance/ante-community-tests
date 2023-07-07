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

/// @title Chainlink feed for ETH/USD updates according to its heartbeat (27s)
/// @notice Checks if the ETH/USD feed on Polygon updates according to its heartbeat (27s)
contract AnteChainlinkETHUSDonPolygonDatafeedHeartbeatTest is AnteTest("Chainlink feed for ETH/USD on Polygon updates according to heartbeat") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0xF9680D99D6C9589e2a93a78A04A279e509205945);

    uint256 private constant HEARTBEAT = 27;
    uint256 private constant BUFFER = 2 * 6;

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0xF9680D99D6C9589e2a93a78A04A279e509205945
        ];
    }

    /// @return true if the feed has been updated within the heartbeat + 6 blocks
    function checkTestPasses() public view override returns (bool) {
        uint256 currentTimeStamp = block.timestamp;
        uint256 lastUpdate = 0;

        (, , , lastUpdate, ) = datafeed.latestRoundData();
        if (currentTimeStamp - lastUpdate > HEARTBEAT + BUFFER) {
            return false;
        }    

        return true;
    }

    function getCurrentTS() public view returns (uint256) {
        return block.timestamp;
    }

    function getLastUpdateTS() public view returns (uint256) {
        uint256 lastUpdate = 0;
        (, , , lastUpdate, ) = datafeed.latestRoundData();
        return lastUpdate;
    }

    function getTimeFromLastUpdate() public view returns (uint256) {
        uint256 lastUpdate = 0;
        (, , , lastUpdate, ) = datafeed.latestRoundData();
        return getCurrentTS() - lastUpdate;
    }
}
