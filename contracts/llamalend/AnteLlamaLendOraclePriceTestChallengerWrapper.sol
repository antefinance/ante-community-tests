// SPDX-License-Identifier: GPL-3.0-only

// For usage with AnteLlamaLendOraclePriceTest on Ethereum to allow
// challenging the test without being vulnerable to frontrunning.

/*****************************************************
 * ============= IMPORTANT USAGE NOTE ============== *
 *****************************************************/
/// In order to simplify the internal logic of the wrapper contract, only a
/// single user can use each wrapper. Thus, each user attempting to challenge
/// the LlamaLend Ante Pool should deploy their own instance of this wrapper!
/// Also, if you use this wrapper to challenge the Ante Pool and then transfer
/// ownership, then the new owner is the one that can withdraw any funds
/// challenged or claimable from the pool.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/ante-v05-core/interfaces/IAntePool.sol";

interface IAnteLlamaLendOraclePriceTest {
    function setMessageToCheck(
        uint216 price,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

/// @title  Ante LlamaLend Oracle Price Test Challenger
/// @notice Wrapper to interact with Ante Pool for AnteLlamaLendOraclePriceTest
///         in order to prevent front-running a challenger that is attempting
///         to verify the test. This works by allowing the user to set test
///         parameters and verify the test atomically.
contract AnteLlamaLendOraclePriceTestChallengerWrapper is Ownable {
    IAnteLlamaLendOraclePriceTest public immutable test;
    IAntePool public immutable pool;

    constructor(address _anteLlamaLendOraclePriceTestAddress, address _anteLlamaLendOraclePricePoolAddress) {
        test = IAnteLlamaLendOraclePriceTest(_anteLlamaLendOraclePriceTestAddress);
        pool = IAntePool(_anteLlamaLendOraclePricePoolAddress);
    }

    receive() external payable {}

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/

    /// @notice Challenges `msg.value` amount into Ante Pool
    function challenge() external payable onlyOwner {
        pool.stake{value: msg.value}(true);
    }

    /// @notice Withdraws `amount` challenge from Ante Pool
    /// @param  amount Amount to withdraw from the Ante Pool in wei
    function withdrawChallenge(uint256 amount) external onlyOwner {
        pool.unstake(amount, true);
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Withdraws all challenged capital from Ante Pool
    function withdrawChallengeAll() external onlyOwner {
        pool.unstakeAll(true);
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Sets the appropriate setter functions in the Ante Test then
    ///         calls the checkTest function on the Ante Pool. This prevents
    ///         frontrunning of the Ante LlamaLend oracle test.
    /// @param price floor price of collection
    /// @param deadline deadline of floor price validity
    /// @param v part of the message signature
    /// @param r part of the message signature
    /// @param s part of the message signature
    function setParamsAndCheckTest(
        uint216 price,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external onlyOwner {
        // set message state to check
        test.setMessageToCheck(price, deadline, v, r, s);
        // Call checkTest on pool
        pool.checkTest();
    }

    /// @notice Claims any rewards due the challenger from a failed Ante Pool
    function claim() external onlyOwner {
        pool.claim();
        msg.sender.transfer(address(this).balance);
    }
}
