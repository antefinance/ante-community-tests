// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

/// @title Curve stETH Doesn't Rug
contract AnteSTETHCurveRugTest is AnteTest("Curve stETH Keeps 99% of it's ETH.") {
    // https://etherscan.io/address/0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
    address public stETHCurveSwap = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;

    // 2022-04-05: stETH Curve Contract has 800k ETH, so -99% is ~8k ETH
    uint256 public immutable originalBalance;

    constructor() {
        protocolName = "Curve";
        testedContracts = [stETHCurveSwap];
        originalBalance = stETHCurveSwap.balance;
    }

    /// @notice test to check balance of stETH curve pool
    /// @return if stETH Curve pool  has at least 1% the original balance
    function checkTestPasses() public view override returns (bool) {
        return ((100 * stETHCurveSwap.balance) / originalBalance > 1);
    }
}
