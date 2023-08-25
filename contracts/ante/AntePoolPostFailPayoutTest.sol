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

import "../libraries/ante-v06-core/AnteTest.sol";
import "../libraries/ante-v06-core/interfaces/IAntePool.sol";

/// @title Ante Pool contract cannot pay out if test has not failed
/// @notice Connects to deployed Ante Pools to test them
contract AntePoolPostFailPayoutTest is AnteTest("Ante Pool cannot pay out before failure") {
    /// @param _testedContracts array of Ante Pools to check
    constructor(address[] memory _testedContracts) {
        testedContracts = _testedContracts;
        protocolName = "Ante";
    }

    /// @notice test checks that payouts do not happen before failure
    /// @return true if no payouts have happened on unfailed tests
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < testedContracts.length; i++) {
            IAntePool pool = IAntePool(testedContracts[i]);
            if (pool.pendingFailure()) continue;
            if (pool.numPaidOut() > 0) return false;
            if (pool.totalPaidOut() > 0) return false;
        }
        return true;
    }
}
