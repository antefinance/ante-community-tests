// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Supply threshold test for token [TOKEN]
/// @author [AUTHOR]
/// @notice Ante test to check that the supply of [TOKEN] does not
///      exceed the threshold [THRESHOLD]
contract AnteSupplyThresholdTestTemplate is AnteTest("[TOKEN] supply doesn't exceed [THRESHOLD]") {
    address public immutable tokenAddress;
    uint256 public constant THRESHOLD_SUPPLY = [THRESHOLD];
    IERC20 public token;

    constructor() {
        protocolName = [TOKEN];
        testedContracts = [[TOKEN_ADDRESS]];

        tokenAddress = [TOKEN_ADDRESS];
        token = IERC20(tokenAddress);
    }

    /// @notice Test to check token supply against threshold
    /// @return [TOKEN] supply is less than [THRESHOLD]
    function checkTestPasses() external view override returns (bool) {
        return (token.totalSupply() <= THRESHOLD_SUPPLY);
    };
};