// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title AAVE Optimism markets do not lose 85% of their assets
// @notice Ensure that AAVE Optimism markets don't drop under 15% for top 5 tokens
contract AnteTotalSupplyPlungeTest is AnteTest("Ensure that AAVE Optimism markets don't drop under 15% for top 5 tokens") {
    IERC20[5] public tokens = [
      IERC20(0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8), //aOptWETH
      IERC20(0x625E7708f30cA75bfd92586e17077590C60eb4cD), //aOptUSDC
      IERC20(0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE), //aOptDAI
      IERC20(0x078f358208685046a11C85e8ad32895DED33A249), //aOptWBTC
      IERC20(0x6ab707Aca953eDAeFBc4fD23bA73294241490620) //aOptUSDT
    ];

    uint256 private constant PERCENT_DROP_THRESHOLD = 15;

    // threshold amounts under which the test fails
    uint256[5] public thresholds;

    constructor() {
        protocolName = "AAVE";

        for (uint256 i = 0; i < 5; i++) {
            testedContracts.push(address(tokens[i]));
            thresholds[i] = (tokens[i].totalSupply() * PERCENT_DROP_THRESHOLD) / 100;
        }
    }

    function checkTestPasses() external view override returns (bool) {
        for (uint256 i = 0; i < 5; i++) {
            if (tokens[i].totalSupply() < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
