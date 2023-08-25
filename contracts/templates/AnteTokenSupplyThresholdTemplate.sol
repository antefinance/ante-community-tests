// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Total supply threshold test for token [TOKEN]
/// @author [AUTHOR]
/// @notice Ante Test to check that the total supply of [TOKEN] does not
///      exceed [THRESHOLD]
contract AnteTokenSupplyThresholdTestTemplate is AnteTest("[TOKEN] supply doesn't exceed [THRESHOLD]") {
    // TODO update token address
    IERC20 public constant TOKEN = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    // TODO replace with desired supply maximum (including decimals)
    uint256 public constant MAX_SUPPLY_THRESHOLD = 10_000_000_000_000;
    
    constructor() {
        // TODO update protocol name with token name
        protocolName = "[TOKEN]";
        testedContracts = [address(TOKEN)];
    }

    /// @notice Checks token supply against threshold
    /// @return [TOKEN] supply is less than or equal to [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.totalSupply() <= MAX_SUPPLY_THRESHOLD);
    }
}