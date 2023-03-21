// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Optimism L1 Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if Optimism Bridge "rugs" 90% of its value (as of test deployment)
contract AnteOptimismL1BridgeRugTest is AnteTest("Optimism L1 Bridge Doesn't Rug 90% of its value") {
    // https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1
    address public constant optimismL1BridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;

    // Top 6 tokens
    IERC20[6] public tokens = [
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), //USDC
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7), //USDT
        IERC20(0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE), //WBTC
        IERC20(0x01BA67AAC7f75f647D94220Cc98FB30FCc5105Bf), //Lyra
        IERC20(0x865377367054516e17014CcdED1e7d814EDC9ce4), //Dola
        IERC20(0xae78736Cd615f374D3085123A210448E74Fc6393) //rETH
    ];

    uint256 private constant PERCENT_DROP_THRESHOLD = 90;
    uint256 public immutable etherThreshold;

    // threshold amounts under which the test fails
    uint256[6] public thresholds;

    constructor() {
        protocolName = "Optimism Bridge";
        testedContracts = [optimismL1BridgeAddr];

        etherThreshold = (optimismL1BridgeAddr.balance * (100 - PERCENT_DROP_THRESHOLD)) / 100;
        for (uint256 i = 0; i < tokens.length; i++) {
            testedContracts.push(address(tokens[i]));
            thresholds[i] = (tokens[i].balanceOf(optimismL1BridgeAddr) * (100 - PERCENT_DROP_THRESHOLD)) / 100;
        }
    }

    /// @notice test to check value of top 6 assets on Optimism Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when this test was deployed
    function checkTestPasses() public view override returns (bool) {
        if (optimismL1BridgeAddr.balance < etherThreshold) {
            return false;
        }
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].balanceOf(optimismL1BridgeAddr) < thresholds[i]) {
                return false;
            }
        }
        return true;
    }
}
