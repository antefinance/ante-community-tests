// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Supply threshold test for token [TOKEN]
/// @author [AUTHOR]
/// @notice Ante test to check that the supply of [TOKEN] does not
///         exceed the threshold [THRESHOLD]
contract AnteSupplyThresholdTestTemplate is AnteTest("[TOKEN] supply doesn't exceed [THRESHOLD]") {
    // TODO update token address and block explorer link
    // https://etherscan.io/address/0x6123B0049F904d730dB3C36a31167D9d4121fA6B
    IERC20Metadata public constant TOKEN = IERC20Metadata(0x6123B0049F904d730dB3C36a31167D9d4121fA6B);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdSupply;

    constructor() {

        // TODO replace (1000 * 1000) with desired threshold
        thresholdSupply = (1000 * 1000) * (10**TOKEN.decimals());

        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        testedContracts = [address(TOKEN)];
    }

    /// @notice Test to check token supply against threshold
    /// @return [TOKEN] supply is less than [THRESHOLD]
    function checkTestPasses() external view override returns (bool) {
        return (TOKEN.totalSupply() <= thresholdSupply);
    }
}