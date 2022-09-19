// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title  Checks that $IDIA balance held by Impossible Finance multisigs
///         remains >= 10M (1% of total token supply)
/// @notice Ante Test to check if Impossible Finance multisigs have been
///         hacked or rugged
contract AnteImpossibleMultisigIDIATest is AnteTest("Impossible Finance Multisigs $IDIA balance remains >=10M") {
    // https://bscscan.com/address/0x782CB1bC68C949a88f153e2eFc120CC7754E402B
    // https://bscscan.com/address/0xC86217A218996359680D89D242a4EAC93fC607a9
    address public constant IMPOSSIBLE_MULTISIG_1 = 0x782CB1bC68C949a88f153e2eFc120CC7754E402B;
    address public constant IMPOSSIBLE_MULTISIG_2 = 0xC86217A218996359680D89D242a4EAC93fC607a9;
    // https://bscscan.com/address/0x0b15Ddf19D47E6a86A56148fb4aFFFc6929BcB89
    IERC20Metadata public constant IDIA = IERC20Metadata(0x0b15Ddf19D47E6a86A56148fb4aFFFc6929BcB89);
    // Will be set to 10 million IDIA
    uint256 public immutable thresholdBalance;

    constructor() {
        thresholdBalance = (10 * 1000 * 1000) * (10**IDIA.decimals()); // 10 million

        protocolName = "Impossible Finance";
        testedContracts = [IMPOSSIBLE_MULTISIG_1, IMPOSSIBLE_MULTISIG_2];
    }

    /// @notice checks if IDIA balance in Impossible Multisigs is >=10m
    /// @return true if IDIA balance in Impossible-controlled Multisigs >= 10m
    function checkTestPasses() public view override returns (bool) {
        return (IDIA.balanceOf(IMPOSSIBLE_MULTISIG_1) + IDIA.balanceOf(IMPOSSIBLE_MULTISIG_2) >= thresholdBalance);
    }
}
