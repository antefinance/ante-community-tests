// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @author Put your ETH address here
/// @notice Ante Test to check _____
contract AnteTestBlankTemplate is AnteTest("Description of what the test checks") {
    // Here is where any variables you might use can be declared, e.g. token addresses

    constructor() {
        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        // TODO replace 0x0 with any contracts being tested
        testedContracts = [address(0)];
    }

    /// @notice test to check ___________
    /// @return true if [test pass condition]
    function checkTestPasses() public view override returns (bool) {
        // Here is where your test logic goes!
        return (true);
    }
}
