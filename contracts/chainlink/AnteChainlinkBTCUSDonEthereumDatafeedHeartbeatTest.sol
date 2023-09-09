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

/// @title Chainlink feed for BTC/USD updates according to its heartbeat (1hr)
/// @notice Checks if the BTC/USD feed on Ethereum updates according to its heartbeat (1hr)
contract AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest is AnteTest("Chainlink feed for BTC/USD on Ethereum updates according to heartbeat") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);

    uint256 private constant HEARTBEAT = 3600;
    uint256 private constant BUFFER = 72;

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c
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
}
