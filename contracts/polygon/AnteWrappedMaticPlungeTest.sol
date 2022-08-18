// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.7.0;

import "../AnteTest.sol";

/// @title Ante Wrapped Matic Plunge Test
/// @notice Ante Test to check that Wrapped Matic does NOT drop below 2M (as of Aug 2022)
contract AnteWrappedMaticPlungeTest is AnteTest("Wrapped_Matic does NOT drop below 2M") {
    // https://polygonscan.com/address/0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270
    address public immutable w_maticaddr = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    // 2022-08-18: Balance is ~285M MATIC, so -99.3% is ~2M 
    uint256 public constant RUG_THRESHOLD = 2 * 1000000 * 1e18;

    constructor() {
        protocolName = "polygon";
        testedContracts = [w_maticaddr];
    }

    /// @notice test to check balance of wrapped matic 
    /// @return true if wrapped matic is above 2M matic 
    function checkTestPasses() external view override returns (bool) {
        return w_maticaddr.balance >= RUG_THRESHOLD;
    }
}
