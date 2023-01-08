// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title (Demo) Nobody else should know the private key to this public ETH address
/// @notice Ante Test to check that the signature to the message "AntePoPKTest Demo" does not correspond to the testAddress
contract AntePoPKTest is AnteTest("Nobody else knows the private key of this public address") {
    // A non-custom string that is frontrunnable
    string message = "AntePoPKTest Demo";
    bytes32 message_hash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(message)));
    bytes signature;
    // The private key is f9ad1bc6470713365953b2375dcbca1059e469132b968e154525653f6824200c
    address public testAddress = 0x66c777464c62F125760f80254257ed8DFccB2921;

    constructor() {
        protocolName = "ProofOfExploit";
        testedContracts = [address(0)];
    }

    /// @notice Check that the signature submitted does not correspond to the testAddress
    /// @return true if ECDSA.recover(message_hash, signature) != testAddress
    function checkTestPasses() public view override returns (bool) {
        // The signature must have length 65 in order to be valid
        if (signature.length != 65) {
            return true;
        }
        return ECDSA.recover(message_hash, signature) != testAddress;
    }

    /// This is known to be frontrunnable
    function set(bytes memory _signature) public {
        signature = _signature;
    }
}
