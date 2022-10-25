// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @notice Ante Test to check _____
contract AntePoHTest is AnteTest("Description of what the test checks") {
    // Here is where any variables you might use can be declared, e.g. token addresses
    string public preimage; // 123456
    bytes32 public testHash = 0xc888c9ce9e098d5864d3ded6ebcc140a12142263bace3a23a36f9905f12bd64a;

    constructor() {
        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        // TODO replace 0x0 with any contracts being tested
        testedContracts = [address(0)];
    }

    /// @notice test to check if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    /// @return true if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        // Here is where the test logic lives!
        return keccak256(abi.encodePacked(preimage)) != testHash;
    }

    /// This is known to be frontrunnable
    function setPreImage(string memory _preimage) public {
        preimage = _preimage;
    }
}
