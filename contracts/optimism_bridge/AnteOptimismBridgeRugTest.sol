// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Optimism Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if Optimism Bridge "rugs" 90% of its value (as of test deployment)
contract AnteOptimismBridgeRugTest is AnteTest("Optimism Bridge Doesnt Rug 90% of its Value Test") {
    // https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1
    address public constant optimismBridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
    // https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // https://etherscan.io/address/0x5f98805A4E8be255a32880FDeC7F6728C6568bA0
    address public constant lusdAddr = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    // https://etherscan.io/address/0x01BA67AAC7f75f647D94220Cc98FB30FCc5105Bf
    address public constant lyraAddr = 0x01BA67AAC7f75f647D94220Cc98FB30FCc5105Bf;
    // https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address public constant tetherAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 public usdcToken;
    IERC20 public lusdToken;
    IERC20 public lyraToken;
    IERC20 public tetherToken;

    uint256 public immutable etherBalanceAtDeploy;
    uint256 public immutable usdcBalanceAtDeploy;
    uint256 public immutable lusdBalanceAtDeploy;
    uint256 public immutable lyraBalanceAtDeploy;
    uint256 public immutable tetherBalanceAtDeploy;

    constructor() {
        protocolName = "Optimism Bridge";
        testedContracts = [optimismBridgeAddr];

        usdcToken = IERC20(usdcAddr);
        lusdToken = IERC20(lusdAddr);
        lyraToken = IERC20(lyraAddr);
        tetherToken = IERC20(tetherAddr);

        etherBalanceAtDeploy = optimismBridgeAddr.balance;
        usdcBalanceAtDeploy = usdcToken.balanceOf(optimismBridgeAddr);
        lusdBalanceAtDeploy = lusdToken.balanceOf(optimismBridgeAddr);
        lyraBalanceAtDeploy = lyraToken.balanceOf(optimismBridgeAddr);
        tetherBalanceAtDeploy = tetherToken.balanceOf(optimismBridgeAddr);
    }

    /// @notice test to check value of top 5 assets on Optimism Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return
            optimismBridgeAddr.balance * 10 > etherBalanceAtDeploy &&
            usdcToken.balanceOf(optimismBridgeAddr) * 10 > usdcBalanceAtDeploy &&
            lusdToken.balanceOf(optimismBridgeAddr) * 10 > lusdBalanceAtDeploy &&
            lyraToken.balanceOf(optimismBridgeAddr) * 10 > lyraBalanceAtDeploy &&
            tetherToken.balanceOf(optimismBridgeAddr) * 10 > tetherBalanceAtDeploy;
    }
}
