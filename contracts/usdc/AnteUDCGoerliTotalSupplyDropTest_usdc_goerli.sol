// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title USDC Goerli markets do not lose 85% of their assets
// @notice Ensure that USDC Goerli markets don't drop under 15% for top 1 tokens
contract AnteUDCGoerliTotalSupplyDropTest is AnteTest("Ensure that USDC Goerli markets don't drop under 15% for top 1 tokens") {
    IERC20[1] public tokens = [
      IERC20(0x07865c6E87B9F70255377e024ace6630C1Eaa37F) //USDC
    ];

    uint256 private constant PERCENT_DROP_THRESHOLD = 15;

    // threshold amounts under which the test fails
    uint256[1] public thresholds;

    constructor() {
        protocolName = "USDC";

        for (uint256 i = 0; i < tokens.length; i++) {
            testedContracts.push(address(tokens[i]));
            thresholds[i] = (tokens[i].totalSupply() * PERCENT_DROP_THRESHOLD) / 100;
        }
    }

    function checkTestPasses() external view override returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].totalSupply() < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
