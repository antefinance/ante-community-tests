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

/// @title  Ethereum PoS Merge happens before 2023
/// @notice Ante Test to check if The Merge has happened before 2023
contract AnteEthPosMergeBefore2023Test is AnteTest("The Merge (Ethereum PoS) happens before 2023-01-01") {
    constructor() {
        protocolName = "Ethereum";
    }

    /// @notice Checks if the merge has occurred before 2023
    /// @return false if it is 2023-01-01 00:00:00 GMT or later and the difficulty
    ///         bomb has not yet occurred; returns true otherwise
    function checkTestPasses() external view override returns (bool) {
        // After the difficulty bomb, block.difficulty will be > 2**64 or = 0
        if (
            block.timestamp >= 1672531200 && // 2023-01-01 00:00:00 GMT
            block.difficulty < 2**64 &&
            block.difficulty > 0
        ) {
            return false;
        }

        return true;
    }
}
