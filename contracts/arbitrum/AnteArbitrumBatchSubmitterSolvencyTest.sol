// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../libraries/ante-v06-core/AnteTest.sol";

/// @title AnteArbitrumBatchSubmitterSolvencyTest
/// @notice Ante Test to check that Arbitrum: Batch Submitter has enough ETH for gas fees
contract AnteArbitrumBatchSubmitterSolvencyTest is AnteTest("Arbitrum Batch Submitter has more than 0.2 ETH") {
    address public constant BATCH_SUBMITTER_ADDR = 0xC1b634853Cb333D3aD8663715b08f41A3Aec47cc;

    constructor() {
        protocolName = "Arbitrum";
        testedContracts = [BATCH_SUBMITTER_ADDR];
    }

    /// @notice test to check balance of ETH in Arbitrum Batch Submitter
    /// @return true if ETH in Arbitrum bridge is above 0.2 ETH
    function checkTestPasses() public view override returns (bool) {
        return BATCH_SUBMITTER_ADDR.balance >= 2 * 1e17;
    }
}
