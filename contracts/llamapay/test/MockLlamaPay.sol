//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

// Mock LlamaPay contract used only for testing

contract MockLlamaPay {
    struct Payer {
        uint40 lastPayerUpdate;
        uint216 totalPaidPerSec;
    }

    mapping(address => Payer) public payers;

    function createStream(address to, uint216 amountPerSec) public {
        payers[msg.sender].lastPayerUpdate = uint40(block.timestamp);
    }

    function makeFail() public {
        payers[msg.sender].lastPayerUpdate = uint40(block.timestamp + 9001);
    }
}
