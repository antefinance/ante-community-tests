// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";

/// @title Nobody knows the pre-image of this hash
/// @notice Ante Test to check that pre-image of the hash is unknown
contract AntePoHTest is AnteTest("Nobody knows the pre-image of this hash") {
    string public preimage; // The pre-image is 123456
    bytes32 public testHash = 0xc888c9ce9e098d5864d3ded6ebcc140a12142263bace3a23a36f9905f12bd64a;

    constructor() {
        protocolName = "";
    }

    function checkTestPasses() public view override returns (bool) {
        return keccak256(abi.encodePacked(preimage)) != testHash;
    }

    /// This is known to be frontrunnable
    function setPreImage(string memory _preimage) public {
        preimage = _preimage;
    }
}
