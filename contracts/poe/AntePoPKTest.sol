// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @notice Ante Test to check _____
contract AntePoPKTest is AnteTest("Nobody else knows the private key of this public address") {
    // Here is where any variables you might use can be declared, e.g. token addresses
    // A non-custom string that is frontrunnable
    string message = "AntePoPKTest Demo";
    bytes32 message_hash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(message)));
    bytes signature;
    // The private key is f9ad1bc6470713365953b2375dcbca1059e469132b968e154525653f6824200c
    address public testAddress = 0x66c777464c62F125760f80254257ed8DFccB2921;

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
        if (signature.length == 65) {
            return ECDSA.recover(message_hash, signature) != testAddress;
        }
        return true;
    }

    /// This is known to be frontrunnable
    function set(bytes memory _signature) public {
        signature = _signature;
    }
}
