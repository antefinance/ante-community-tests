// SPDX-License-Identifier: MIT
// This contracts runs on L1, and controls a the test on L2.
// The addresses are specific to Optimistic Goerli.
pragma solidity ^0.8.0;

import {ICrossDomainMessenger} from "../ICrossDomainMessenger.sol";

error OnlyOwner();
error AddressNotSet();

/// @title Control the state of the Ante Test on L2
contract FromL1ControlState {
    /// @notice L2 address of the deployed Ante Test
    address public anteTestL2Addr;

    /// @notice The deployer which is allowed to set the ante test address
    address public owner;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Set the L2 Ante Test address.
    /// owner is destroyed in order to keep the test trustless
    function setTestAddress(address _anteTestL2Addr) external onlyOwner {
        anteTestL2Addr = _anteTestL2Addr;
        // Destroy the owner
        owner = address(0);
    }

    /// @notice Compose the state and send the message to L2
    function sendState() public {
        if (anteTestL2Addr == address(0)) {
            revert AddressNotSet();
        }

        bytes memory message;

        bytes memory state = abi.encode(msg.sender, block.timestamp);
        message = abi.encodeWithSignature("setTimestamp(bytes)", state);

        ICrossDomainMessenger(getCrossDomainMessengerAddr()).sendMessage(
            anteTestL2Addr,
            message,
            1000000 // within the free gas limit amount
        );
    }

    /// @notice Returns the L1 address of Optimism Bridge Cross Domain Messenger
    function getCrossDomainMessengerAddr() internal view returns (address addr) {
        // Goerli
        if (block.chainid == 5) return 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

        return 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;
    }
}
