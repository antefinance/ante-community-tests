// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./AntePoPKSnarkVerifier.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @notice Ante Test to check _____
contract AntePoPKSnarkTest is AnteTest("Nobody knows the private key to this public address") {
    // This is the public address that this AnteTest was written for
    address public testAddress = 0x66c777464c62F125760f80254257ed8DFccB2921;
    Verifier private verifier;
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
    uint[1] input;

    constructor(Verifier _verifier) {
        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        // TODO replace 0x0 with any contracts being tested
        testedContracts = [address(0)];

        verifier = _verifier;
    }

    /// @notice test to check if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    /// @return true if $[TOKEN] balance in [TARGET] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        // Here is where the test logic lives!
        return !verifier.verifyProof(a, b, c, input);
    }

    /// This is known to be frontrunnable
    function setCalldata(
        uint[2] memory _a,
        uint[2][2] memory _b,
        uint[2] memory _c,
        uint[1] memory _input
    ) public {
        a = _a;
        b = _b;
        c = _c;
        input = _input;
    }
}
