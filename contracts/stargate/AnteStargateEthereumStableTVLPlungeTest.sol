// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title  Stargate Stablecoin TVL Plunge Test (Ethereum)
// @notice Ante Test to check that stablecoin assets in Stargate pools on
//         Ethereum do not plunge by 90% from the time of test deploy
contract AnteStargateEthereumStableTVLPlungeTest is
    AnteTest("Stargate Stablecoin TVL on Ethereum does not plunge by 90%")
{
    address constant STARGATE_USDT_POOL = 0x38EA452219524Bb87e18dE1C24D3bB59510BD783;
    address constant STARGATE_USDC_POOL = 0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56;

    IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 immutable tvlThreshold;

    constructor() {
        protocolName = "Stargate";
        testedContracts = [STARGATE_USDT_POOL, STARGATE_USDC_POOL];

        tvlThreshold = getCurrentBalances() / 10;
    }

    // @notice Get current pool balances
    // @return the sum of tested stablecoin pool balances
    function getCurrentBalances() public view returns (uint256) {
        return (USDT.balanceOf(STARGATE_USDT_POOL) + USDC.balanceOf(STARGATE_USDC_POOL));
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (getCurrentBalances() > tvlThreshold);
    }
}
