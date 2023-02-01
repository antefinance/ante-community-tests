// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks Polygon Foundation holds >= 5M $MATIC on Eth Mainnet
/// @author Put your ETH address here
/// @notice Ante Test to check
contract AntePolygonFoundationBalanceTest is AnteTest("Polygon Foundation holds >= 5M $MATIC on Eth Mainnet") {
    // https://etherscan.io/address/0xb316fa9Fa91700D7084D377bfdC81Eb9F232f5Ff
    address public constant HOLDER_ADDRESS = 0xb316fa9Fa91700D7084D377bfdC81Eb9F232f5Ff;

    // https://etherscan.io/address/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0
    IERC20Metadata public constant TOKEN = IERC20Metadata(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        thresholdBalance = 5000000 * (10**TOKEN.decimals());

        protocolName = "Polygon";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if $[TOKEN] balance in [HOLDER] is >= [THRESHOLD]
    /// @return true if $[TOKEN] balance in [HOLDER] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
