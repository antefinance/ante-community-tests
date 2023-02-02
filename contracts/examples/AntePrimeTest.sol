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
contract AntePrimeTest is AnteTest("Description of what the test checks") {
    // Here is where any variables you might use can be declared, e.g. token addresses
    uint256 prime_candidate = 1001;
    uint256 factor_one;
    uint256 factor_two;

    constructor() {
    }

    /// @notice test to check ___________
    /// @return true if [test pass condition]
    function checkTestPasses() public view override returns (bool) {
        // Here is where your test logic goes!
        if (factor_one != 1 && factor_two != 1) {
            if (factor_one * factor_two == prime_candidate) {
                return (false);
            }
        }
        return (true);
    }

    function setFactors(uint256 _factor_one, uint256 _factor_two) public {
        factor_one = _factor_one;
        factor_two = _factor_two;
    }
}
