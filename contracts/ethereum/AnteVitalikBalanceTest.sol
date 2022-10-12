// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks USDC balance in vitalik.eth remains >= 1
/// @notice Ante Test to check
contract AnteVitalikBalanceTest is AnteTest("vitalik.eth USDC balance remains >= 1") {
    // vitalik.eth as of 2022-10-12 resolves to the following address
    // https://etherscan.io/address/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
    address public constant HOLDER_ADDRESS = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

    // https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    IERC20Metadata public constant TOKEN = IERC20Metadata(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        thresholdBalance = (1) * (10**TOKEN.decimals());

        protocolName = "Ethereum";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if USDC balance in vitalik.eth is >= 1
    /// @return true if USDC balance in vitalik.eth is >= 1
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
