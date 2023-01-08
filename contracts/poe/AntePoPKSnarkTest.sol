// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./AntePoPKSnarkVerifier.sol";


/// @title Nobody knows the private key to public address
contract AntePoPKSnarkTest is AnteTest("Nobody knows the private key to this public address") {
    // This is the public address that this AnteTest was written for
    address public testAddress = 0x66c777464c62F125760f80254257ed8DFccB2921;
    PoPKVerifier private verifier;
    address private verifierAddress;
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
    uint[1] input;

    constructor(address _verifierAddress) {
        protocolName = "";

        testedContracts = [_verifierAddress];

        verifierAddress = _verifierAddress;
        verifier = PoPKVerifier(verifierAddress);
    }

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
