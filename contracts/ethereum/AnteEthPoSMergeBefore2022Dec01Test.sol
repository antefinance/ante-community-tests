// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "../libraries/ante-v05-core/AnteTest.sol";

/// @title  Ethereum PoS Merge happens before 2022-12-01 (Beacon Chain turns 2 yrs old)
/// @notice Ante Test to check if The Merge between Ethereum PoW and PoS has happened
///         before 2022-12-01 12:00:23 UTC. This marks the 2-year anniversary of the
///         genesis block of the Beacon Chain PoS system.
///         (see https://beaconscan.com/slot/0)
contract AnteEthPoSMergeBefore2022Dec01Test is
    AnteTest("The Merge (Ethereum PoS) happens before 2022-12-01 (Beacon Chain turns 2 yrs old)")
{
    constructor() {
        protocolName = "Ethereum";
    }

    /// @notice Checks if the merge has occurred before the Beacon Chain's 2nd birthday
    /// @return false if it is 2022-12-01 12:00:23 UTC or later and the difficulty
    ///         bomb has not yet occurred; returns true otherwise
    function checkTestPasses() external view override returns (bool) {
        // After the difficulty bomb, block.difficulty will be > 2**64 or = 0
        if (
            block.timestamp >= 1669896023 && // 2022-12-01 12:00:23 UTC
            block.difficulty < 2**64 &&
            block.difficulty > 0
        ) {
            return false;
        }

        return true;
    }
}
