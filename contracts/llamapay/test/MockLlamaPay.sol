//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

// Mock LlamaPay contract used only for testing

contract MockLlamaPay {
    struct Payer {
        uint40 lastPayerUpdate;
        uint216 totalPaidPerSec;
    }

    mapping(address => Payer) public payers;

    event StreamCreated(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId);

    constructor() {}

    function createStream(address to, uint216 amountPerSec) public {
        Payer storage payer = payers[msg.sender];
        payer.lastPayerUpdate = uint40(block.timestamp);
        payer.totalPaidPerSec += amountPerSec;
    }

    function makeFail() public {
        Payer storage payer = payers[msg.sender];
        payer.lastPayerUpdate = uint40(block.timestamp + 9001);
    }
}
