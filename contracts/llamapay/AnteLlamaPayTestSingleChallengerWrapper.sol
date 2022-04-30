// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Works with the AnteLlamaPay Test

pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AnteTest} from "../AnteTest.sol";
import {AntePool} from "../AntePool.sol";

/*****************************************************
 * ============= IMPORTANT USAGE NOTE ============== *
 *****************************************************/
/// In order to simplify the internal logic of the wrapper contract, only a
/// single user can use each wrapper. Thus, each user attempting to challenge
/// the LlamaPay Ante Pool should deploy their own instance of this wrapper!

/// @title  Ante LlamaPay Test Challenger
/// @notice Wrapper to interact with Ante Pool for AnteLlamaPayTest in order to
///         prevent front-running a challenger that is attempting to verify the
///         test. This works by allowing the user to set test parameters and
///         verify the test in the same transaction.
contract AnteLlamaPayTestSingleChallengerWrapper is Ownable {
    // https://etherscan.io/address/[LLAMAPAY_ANTE_TEST_ADDRESS]
    AnteTest public immutable test;

    // https://etherscan.io/address/[LLAMAPAY_ANTE_POOL_ADDRESS]
    AntePool public immutable pool;

    constructor(address _anteLlamaPayTestAddress, address _anteLlamaPayPoolAddress) {
        test = AnteTest(_anteLlamaPayTestAddress);
        pool = AntePool(_anteLlamaPayPoolAddress);
    }

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/

    /// @notice Challenges `msg.value` amount into Ante Pool
    function challenge() external payable onlyOwner {
        pool.stake{value: msg.value}(true);
    }

    /// @notice Withdraws `amount` challenge from Ante Pool
    /// @param amount Amount to withdraw from the Ante Pool in wei
    function unchallenge(uint256 amount) external onlyOwner {
        pool.unstake(amount, true);
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Withdraws all challenged capital from Ante Pool
    function unChallengeAll() external onlyOwner {
        pool.unstakeAll(true);
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Sets the appropriate setter functions in the Ante Test then
    ///         calls the checkTest function on the Ante Pool. This prevents
    ///         frontrunning of the Ante LlamaPay Test.
    /// @param _tokenAddress address of token to check LlamaPay instance for.
    ///        If 0x0 is set, the Ante Test will check all LlamaPay instances
    /// @param _payerAddress address of payer to check
    function checkTest(address _tokenAddress, address _payerAddress) external onlyOwner {
        // set token and payer addresses
        test.setTokenAddress(_tokenAddress);
        test.setPayerAddress(_payerAddress);
        // Call checkTest on pool
        pool.checkTest();
    }

    /// @notice Claims any rewards due the challenger from a failed Ante Pool
    function claim() external onlyOwner {
        pool.claim();
        msg.sender.transfer(address(this).balance);
    }

    /// Note: The staker functions don't require this wrapper because they
    /// aren't vulnerable to front-running, but they (and other functions) have
    /// been included below for completeness (i.e. there is nothing you can do
    /// with the AntePool contract directly that you can't with this wrapper).

    /// @notice Stakes `msg.value` amount into Ante Pool
    function stake() external payable onlyOwner {
        pool.stake{value: msg.value}(false);
    }

    /// @notice Initiates 24 hr unstake period for `amount` staked in Ante Pool
    /// @param amount Amount to withdraw from the Ante Pool in wei
    function startUnstake(uint256 amount) external onlyOwner {
        pool.unstake(amount, false);
    }

    /// @notice Initiates 24 hr unstake period for all staked capital in Ante Pool
    function startUnstakeAll() external onlyOwner {
        pool.unstakeAll(false);
    }

    /// @notice Withdraws staked capital eligible for withdrawal from Ante Pool
    ///         (must first call startUnstake or startUnstakeaAll then wait 24 hours)
    function unstake() external onlyOwner {
        pool.withdrawStake();
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Cancels a pending withdrawal of stake (after startUnstake or
    ///         startUnstakeAll has been called)
    function cancelPendingWithdraw() external onlyOwner {
        pool.cancelPendingWithdraw();
    }

    /// @notice Updates decay calculations in the Ante Pool
    function updateDecay() public onlyOwner {
        pool.updateDecay();
    }
}
