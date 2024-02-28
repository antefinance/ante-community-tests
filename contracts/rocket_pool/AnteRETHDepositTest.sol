// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import { AnteTest } from "../AnteTest.sol";


/// @title Checks ETH deposited in rETH to be >10% of amount as deployed
/// @author 0xa00E9Cf403B0C5F96b34C00203997d972c6a0B22
contract AnteRETHDepositTest is AnteTest("ETH in rETH contract remains above 10% of as of deployed amount") {
    // https://etherscan.io/address/0xae78736Cd615f374D3085123A210448E74Fc6393
    address public constant RETH_ADDRESS = 0xae78736Cd615f374D3085123A210448E74Fc6393;

    uint256 public immutable thresholdBalance;

    constructor() {
      thresholdBalance = RETH_ADDRESS.balance / 10;

      protocolName = "Rocket Pool";
      testedContracts = [RETH_ADDRESS];
    }

    /// @notice Test the ETH balance in RETH token
    /// @return true if ETH balance is above thresholdBalance
    function checkTestPasses() public view override returns (bool) {
      return (RETH_ADDRESS.balance >= thresholdBalance);
    }
}
