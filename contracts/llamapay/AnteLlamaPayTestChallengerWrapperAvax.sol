// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// For usage with AnteLlamaPayTest on Avalanche to allow challenging the test
// without being vulnerable to frontrunning.

/*****************************************************
 * ============= IMPORTANT USAGE NOTE ============== *
 *****************************************************/
/// In order to simplify the internal logic of the wrapper contract, only a
/// single user can use each wrapper. Thus, each user attempting to challenge
/// the LlamaPay Ante Pool should deploy their own instance of this wrapper!

pragma solidity ^0.7.0;

import "@openzeppelin-contracts-old/contracts/access/Ownable.sol";
import "../libraries/ante-v05-avax/interfaces/IAntePool.sol";

interface IAnteLlamaPayTest {
    function setTokenAddress(address _tokenAddress) external;

    function setPayerAddress(address _payerAddress) external;
}

/// @title  Ante LlamaPay Test Challenger
/// @notice Wrapper to interact with Ante Pool for AnteLlamaPayTest in order to
///         prevent front-running a challenger that is attempting to verify the
///         test. This works by allowing the user to set test parameters and
///         verify the test in the same transaction.
contract AnteLlamaPayTestChallengerWrapper is Ownable {
    // https://snowtrace.io/address/0x4c008a686899F9a745C394A8C42d4a4Cb89F23A5
    IAnteLlamaPayTest public immutable test;

    // https://snowtrace.io/address/0x99eDEcfE4FE9c2d760b30E782eA0E6C87Bd2F3ac
    IAntePool public immutable pool;

    constructor(address _anteLlamaPayTestAddress, address _anteLlamaPayPoolAddress) {
        test = IAnteLlamaPayTest(_anteLlamaPayTestAddress);
        pool = IAntePool(_anteLlamaPayPoolAddress);
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
    ///         frontrunning of the Ante LlamaPay Test.
    /// @param  _tokenAddress address of token to check LlamaPay instance for.
    ///         If 0x0 is set, the Ante Test will check all LlamaPay instances
    /// @param  _payerAddress address of payer to check
    function setParamsAndCheckTest(address _tokenAddress, address _payerAddress) external onlyOwner {
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
}
