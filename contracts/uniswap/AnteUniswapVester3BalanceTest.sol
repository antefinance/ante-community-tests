// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks that $UNI balance in Uniswap Treasury Vester 3 remains >= 
///        minimum amount according to vesting schedule
/// @notice Ante Test to check that Uniswap Treasury Vester 3 doesn't vest
///         faster than the published schedule
contract AnteUniswapVester3BalanceTest is AnteTest("Uniswap Treasury Vester 3 does not vest faster than schedule") {
    // https://etherscan.io/address/0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
    IERC20Metadata public constant UNI = IERC20Metadata(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);

    // https://etherscan.io/address/0x4b4e140D1f131fdaD6fb59C13AF796fD194e4135
    address public constant TREASURY_VESTER_3 = 0x4b4e140D1f131fdaD6fb59C13AF796fD194e4135;

    uint256 public constant VESTING_AMOUNT = 86_000_000 * 10**18;
    uint256 public constant VESTING_BEGIN = 1663459200;
    uint256 public constant VESTING_CLIFF = 1663459200;
    uint256 public constant VESTING_END = 1694995200;

    constructor() {
        protocolName = "Uniswap";

        testedContracts = [address(UNI), TREASURY_VESTER_3];
    }

    /// @notice checks if $UNI balance in Uniswap Treasury Vester 3 has
    ///         decreased faster than the vesting schedule allows
    /// @return true if $UNI balance in Uniswap Treasury Vester 3 is >= the 
    ///         minimum amount possible remaining according to vesting schedule
    function checkTestPasses() public view override returns (bool) {
        // If after vesting end, threshold = 0
        if (block.timestamp > VESTING_END) return (UNI.balanceOf(TREASURY_VESTER_3) >= 0);
        // If before vesting cliff, threshold = VESTING_AMOUNT
        if (block.timestamp < VESTING_CLIFF) return (UNI.balanceOf(TREASURY_VESTER_3) >= VESTING_AMOUNT);
        // Otherwise, threshold = VESTING_AMOUNT - VESTING_AMOUNT * 
        // (block.timestamp - VESTING_BEGIN) / (VESTING_END - VESTING_BEGIN)
        return (
            UNI.balanceOf(TREASURY_VESTER_3) >= 
            VESTING_AMOUNT - VESTING_AMOUNT * 
            (block.timestamp - VESTING_BEGIN) / 
            (VESTING_END - VESTING_BEGIN)
        );
    }

    /// @notice current failure balance threshold
    function getThresholdBalance() public view returns (uint256) {
        if (block.timestamp > VESTING_END) return 0;
        if (block.timestamp < VESTING_CLIFF) return VESTING_AMOUNT;
        return VESTING_AMOUNT - VESTING_AMOUNT * 
            (block.timestamp - VESTING_BEGIN) / 
            (VESTING_END - VESTING_BEGIN);
    }
}
