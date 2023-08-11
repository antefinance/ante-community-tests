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

/// @title Chainlink feed for BNB/USD updates according to its heartbeat (27s)
/// @notice Checks if the BNB/USD feed on BSC updates according to its heartbeat (27s)
contract AnteChainlinkBNBUSDonBSCDatafeedHeartbeatTest is AnteTest("Chainlink feed for BNB/USD on BSC updates according to heartbeat") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

    uint256 private constant HEARTBEAT = 27;
    uint256 private constant BUFFER = 2 * 2; //2 blocks

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        ];
    }

    /// @return true if the feed has been updated within the heartbeat + 2 blocks
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
