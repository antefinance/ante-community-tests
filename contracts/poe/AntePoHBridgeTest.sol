// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./bridge.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @notice Ante Test to check _____
contract AntePoHBridgeTest is AnteTest("Nobody knows the pre-image of this hash which the bridge needs for some reason") {
    // Here is where any variables you might use can be declared, e.g. token addresses
    string public preimage; // The pre-image is 123456
    bytes32 public testHash = 0xc888c9ce9e098d5864d3ded6ebcc140a12142263bace3a23a36f9905f12bd64a;
    address public bridgeAddr;
    TokenBridge private bridge; 

    constructor(address _bridgeAddr) {
        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        // TODO replace 0x0 with any contracts being tested
        testedContracts = [address(0)];

        bridgeAddr = _bridgeAddr;
        bridge = TokenBridge(bridgeAddr);
    }

    /// @notice test to check if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    /// @return true if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    function checkTestPasses() public override returns (bool) {
        // Here is where the test logic lives!
        bool result = keccak256(abi.encodePacked(preimage)) != testHash;
        // The callback function
        if (!result) {
            bridge.disable();
        }
        return result;
    }

    /// This is known to be frontrunnable
    function setPreImage(string memory _preimage) public {
        preimage = _preimage;
    }
}
