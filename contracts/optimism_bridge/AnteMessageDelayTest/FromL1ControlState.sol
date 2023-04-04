// SPDX-License-Identifier: MIT
// This contracts runs on L1, and controls a the test on L2.
// The addresses are specific to Optimistic Goerli.
pragma solidity ^0.8.0;

import {ICrossDomainMessenger} from "../ICrossDomainMessenger.sol";

/// @title Control the state of the Ante Test on L2
contract FromL1ControlState {
    /// @notice L1 address of Optimism Bridge Cross Domain Messenger
    /// Ethereum Mainnet - 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1
    /// Ethereum Goerli - 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294
    address public crossDomainMessengerAddr = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;

    /// @notice L2 address of the deployed Ante Test
    address public anteTestL2Addr;

    constructor(address _anteTestL2Addr) {
        anteTestL2Addr = _anteTestL2Addr;
    }

    /// @notice Compose the state and send the message to L2
    function sendState() public {
        bytes memory message;

        bytes memory state = abi.encodePacked(msg.sender, block.timestamp);
        message = abi.encodeWithSignature("setTimestamp(bytes)", state);

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            anteTestL2Addr,
            message,
            1000000 // within the free gas limit amount
        );
    }
}
