// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "./bridge.sol";

/// @title Ante test that checks that no one knows the pre-image of specific hash
/// @notice Ante Test to check pre-image of hash is unknown
contract AntePoHBridgeTest is
    AnteTest("Nobody knows the pre-image of this hash which the bridge needs for some reason")
{
    string public preimage; // The pre-image is 123456
    bytes32 public testHash = 0xc888c9ce9e098d5864d3ded6ebcc140a12142263bace3a23a36f9905f12bd64a;
    address public bridgeAddr;
    TokenBridge private bridge;

    constructor(address _bridgeAddr) {
        protocolName = "ProofOfExploit";

        testedContracts = [_bridgeAddr];

        bridgeAddr = _bridgeAddr;
        bridge = TokenBridge(bridgeAddr);
    }

    function checkTestPasses() public override returns (bool) {
        bool result = keccak256(abi.encodePacked(preimage)) != testHash;
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
