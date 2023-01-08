// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./AntePoMultiSigPKSnarkVerifier.sol";


/// @title Checks that no one knows the private key for an address
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
        protocolName = "";

        testedContracts = [_verifierAddress];

        verifierAddress = _verifierAddress;
        verifier = PoMultiSigPKVerifier(verifierAddress);
    }

    function checkTestPasses() public view override returns (bool) {
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
