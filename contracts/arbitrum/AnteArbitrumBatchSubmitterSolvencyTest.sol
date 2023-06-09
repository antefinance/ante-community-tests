// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../libraries/ante-v06-core/AnteTest.sol";

/// @title AnteArbitrumBatchSubmitterSolvencyTest
/// @notice Ante Test to check that Arbitrum: Batch Submitter is always refunded for gas
contract AnteArbitrumBatchSubmitterSolvencyTest is AnteTest("Arbitrum Batch Submitter is always refunded") {
    address public constant BATCH_SUBMITTER_ADDR = 0xC1b634853Cb333D3aD8663715b08f41A3Aec47cc;
    uint256 public threshold;

    constructor() {
        protocolName = "Arbitrum";
        testedContracts = [BATCH_SUBMITTER_ADDR];
        threshold = BATCH_SUBMITTER_ADDR.balance;
    }

    /// @notice test to check balance of ETH in Arbitrum Batch Submitter
    /// @return true if ETH in Arbitrum bridge is above balance on Test deployment
    function checkTestPasses() public view override returns (bool) {
        return BATCH_SUBMITTER_ADDR.balance >= threshold;
    }
}
