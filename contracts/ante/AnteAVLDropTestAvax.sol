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

import "@openzeppelin-contracts-old/contracts/math/SafeMath.sol";
import "../libraries/ante-v05-avax/AnteTest.sol";

/// @title  Ante doesn't lose 99% of its AVL on Avalanche Test
/// @notice Ante Test to check that tested Ante Pools on Avalanche don't lose
///         99% of their AVAX from the time this test is deployed
contract AnteAVLDropTestAvax is AnteTest("Ante doesnt lose 99% of its AVL on Avalanche") {
    using SafeMath for uint256;

    uint256 public avlThreshold;

    /// @dev Array of contract addresses on Avalanche to test should be passed in when deploying
    /// @param _testedContracts array of addresses to Ante Pools to check
    constructor(address[] memory _testedContracts) {
        protocolName = "Ante";
        testedContracts = _testedContracts;

        // Calculate test failure threshold using 99% drop in total AVL at time of deploy
        avlThreshold = getCurrentAVL().div(100);
    }

    /// @notice checks if the total AVL across tested contracts is less than the failure threshold
    /// @return true if total balance across tested contracts is greater than or equal to avlThreshold
    function checkTestPasses() public view override returns (bool) {
        return getCurrentAVL() >= avlThreshold;
    }

    /// @notice sums up the current total AVL across tested contracts
    /// @return sum of current balances across tested contracts
    function getCurrentAVL() public view returns (uint256) {
        uint256 currentAVL;

        for (uint256 i = 0; i < testedContracts.length; i++) {
            currentAVL = currentAVL.add(testedContracts[i].balance);
        }

        return currentAVL;
    }
}
