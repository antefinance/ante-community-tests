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

/// @title Chainlink feed for ETH/USD updates according to its heartbeat (1hr)
/// @notice Checks if the ETH/USD feed on Ethereum updates according to its heartbeat (1hr)
contract AnteChainlinkETHUSDonEthereumDatafeedHeartbeatTest is AnteTest("Chainlink feed for ETH/USD on Ethereum updates according to heartbeat") {
    
    AggregatorV3Interface datafeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    uint256 private constant HEARTBEAT = 3600;
    uint256 private constant BUFFER = 72;

    constructor() {
        protocolName = "Chainlink";
        testedContracts = [
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
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
