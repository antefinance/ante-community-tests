// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks VELO balance in Velodrome Rewards Distributor remains >= 50K
/// @author 0xacd5443c888301BC2A767DB1B11D1C7E5Fa98002
/// @notice Ante Test to check
contract AnteVeloTokenBalanceAbove50K is AnteTest("Velodrome Rewards Distributor VELO balance remains >= 50K") {
    // TODO update tokenholder address and block explorer link
    // https://etherscan.io/address/0x5d5bea9f0fc13d967511668a60a3369fd53f784f
    address public constant HOLDER_ADDRESS = 0x5d5Bea9f0Fc13d967511668a60a3369fD53F784F;

    // TODO update token address and block explorer link
    // https://etherscan.io/address/0x3c8b650257cfb5f272f799f5e2b4e65093a11a05
    IERC20Metadata public constant TOKEN = IERC20Metadata(0x3c8B650257cFb5f272f799F5e2b4e65093a11a05);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        // TODO replace (1000 * 1000) with desired threshold
        thresholdBalance = (50 * 1000) * (10**TOKEN.decimals());

        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Velodrome";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if VELO balance in Reward distributor is >= 50K
    /// @return true if VELO balance in Reward distributor is >= 50K
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
