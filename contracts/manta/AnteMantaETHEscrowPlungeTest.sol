// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import { AnteTest } from "../AnteTest.sol";

/// @title Manta Pacifc ETH Escrow plunge test
/// @author 0x11d1f1945414B60c4aC9e850dfD7bEB6B153d128
/// @notice Ante test takes ETH at deployment and compares to set threshold (10%)
contract AnteMantaETHEscrowPlungeTest is AnteTest("Manta's Eth Escrow doesn't drop below 10% of its ETH at deployment") {
    // https://etherscan.io/address/0x9168765ee952de7c6f8fc6fad5ec209b960b7622
    address public constant mantaETHEscrowAddress= 0x9168765EE952de7C6f8fC6FaD5Ec209B960b7622;

    // threshold amount for the test to fail
    uint256 public immutable threshold;

    /// @notice percent drop threshold (set to 10%)
    uint256 public constant PERCENT_DROP_THRESHOLD = 10;

    uint256 public immutable etherBalanceAtDeploy;

    constructor() {
        protocolName = "Blast";
        testedContracts = [mantaETHEscrowAddress];

        etherBalanceAtDeploy = mantaETHEscrowAddress.balance;

        threshold = etherBalanceAtDeploy * (PERCENT_DROP_THRESHOLD / 100);
    }

    /// @notice test to check balance of eth
    /// @return true if Manta's ETH Escrow doesn't drop under 10% of the balance at the time of deployment
    function checkTestPasses() public view override returns (bool) {
        return (mantaETHEscrowAddress.balance > threshold);
    }
}
