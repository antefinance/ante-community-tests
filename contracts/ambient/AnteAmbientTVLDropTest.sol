// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

/// @title AnteAmbientTVLDropTest
/// @notice Ante Test to check that ETH and USDC in Ambient's Swap Dex remains above 90% of as of deployment
contract AnteArbitrumPlungeTest is AnteTest("ETH in Arbitrum bridge does NOT drop below 7K") {

    // https://etherscan.io/address/0xAaAaAAAaA24eEeb8d57D431224f73832bC34f688
    address public constant ambientSwapDexAddr = 0xAaAaAAAaA24eEeb8d57D431224f73832bC34f688;

    IERC20 public constant usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    uint256 public immutable thresholdEth;
    uint256 public immutable thresholdUsdc;

    constructor() {
        protocolName = "ambient";

        thresholdEth = ambientSwapDexAddr.balance;
        thresholdUsdc = usdcToken.balanceOf(ambientSwapDexAddr);

        testedContracts = [ambientSwapDexAddr];
    }

    /// @notice test to check balance of ETH and USDC in Ambient's Swap Dex
    /// @return true if both ETH and USDC in Ambient's Swap Dex remains above 10% as of the deployment amount
    function checkTestPasses() public view override returns (bool) {
        return (
            ambientSwapDexAddr.balance < thresholdEth / 10 &&
            usdcToken.balanceOf(ambientSwapDexAddr) < thresholdUsdc / 10
        );
    }
}
