// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title  Stargate TVL Plunge Test (Fantom)
// @notice Ante Test to check that assets in Stargate pools on Fantom
//         (currently USDC) do not plunge by 90% from the time of test deploy
contract AnteStargateFantomTVLPlungeTest is AnteTest("Stargate TVL on Fantom does not plunge by 90%") {
    address constant STARGATE_USDC_POOL = 0x12edeA9cd262006cC3C4E77c90d2CD2DD4b1eb97;

    IERC20 constant USDC = IERC20(0x04068DA6C83AFCFA0e13ba15A6696662335D5B75);

    uint256 immutable tvlThreshold;

    constructor() {
        protocolName = "Stargate";
        testedContracts = [STARGATE_USDC_POOL];

        tvlThreshold = USDC.balanceOf(STARGATE_USDC_POOL) / 10;
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (USDC.balanceOf(STARGATE_USDC_POOL) > tvlThreshold);
    }
}
