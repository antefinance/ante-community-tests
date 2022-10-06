// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[Target][Token]BalanceAbove[Threshold]Test
// TODO 2. Update target protocol, tokenholder address, token, and balance threshold (marked with TODO)
// TODO 3. Replace instances of [TOKEN], [HOLDER], and [THRESHOLD] as needed

/// @title Checks $[TOKEN] balance in [HOLDER] remains >= [THRESHOLD]
/// @notice Ante Test to check
contract AnteTokenBalanceTestTemplate is AnteTest("[HOLDER] [TOKEN] balance remains >= [THRESHOLD]") {
    // TODO update tokenholder address and block explorer link
    // https://etherscan.io/address/0xdaeada3d210d2f45874724beea03c7d4bbd41674
    address public constant HOLDER_ADDRESS = 0xDAEada3d210D2f45874724BeEa03C7d4BBD41674;

    // TODO update token address and block explorer link
    // https://etherscan.io/address/0x6123B0049F904d730dB3C36a31167D9d4121fA6B
    IERC20Metadata public constant TOKEN = IERC20Metadata(0x6123B0049F904d730dB3C36a31167D9d4121fA6B);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        // TODO replace (1000 * 1000) with desired threshold
        thresholdBalance = (1000 * 1000) * (10**TOKEN.decimals());

        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if $[TOKEN] balance in [HOLDER] is >= [THRESHOLD]
    /// @return true if $[TOKEN] balance in [HOLDER] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
