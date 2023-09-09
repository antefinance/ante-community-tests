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

/// @title Chainlink feed for AVAX/USD updates according to its heartbeat (120s)
/// @notice Checks if the AVAX/USD feed on Avalanche updates according to its heartbeat (120s)
contract AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest is AnteTest("Chainlink feed for AVAX/USD on Avalanche updates according to heartbeat") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0x0A77230d17318075983913bC2145DB16C7366156);

    uint256 private constant HEARTBEAT = 120;
    uint256 private constant BUFFER = 2 * 6;

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x0A77230d17318075983913bC2145DB16C7366156
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
