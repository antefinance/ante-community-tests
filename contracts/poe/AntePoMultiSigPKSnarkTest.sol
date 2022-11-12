// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./AntePoMultiSigPKSnarkVerifier.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[DescriptiveNameInCamelCase]Test
// TODO 2. Update checkTestPasses with pass/fail logic

/// @title This should succinctly explain what the Ante Test checks
/// @notice Ante Test to check _____
contract AntePoMultiSigPKSnarkTest is AnteTest("Nobody knows a private key for one of these addresses") {
    // These are the public addresses that this AnteTest was written for
    address public testAddress1 = 0x66c777464c62F125760f80254257ed8DFccB2921;
    address public testAddress2 = 0x09f1eF9171202A72d0854D421244b2361509dCEd;
    address public testAddress3 = 0x3CF58a049f731E5F278304CAF98B4699129e6A1D;
    PoMultiSigPKVerifier private verifier;
    address private verifierAddress;
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
    uint[5] input;

    constructor(address _verifierAddress) {
        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "Protocol";

        // TODO replace 0x0 with any contracts being tested
        testedContracts = [address(0)];

        verifierAddress = _verifierAddress;
        verifier = PoMultiSigPKVerifier(verifierAddress);
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
        uint[5] memory _input
    ) public {
        a = _a;
        b = _b;
        c = _c;
        input = _input;
    }
}
