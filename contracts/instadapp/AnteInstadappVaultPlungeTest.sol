// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import { AnteTest } from "../AnteTest.sol";
import { IERC20 } from "../interfaces/IERC20.sol";

/// @title Instadapp Vault stETH plunge test
/// @author 0x11d1f1945414B60c4aC9e850dfD7bEB6B153d128
/// @notice Ante test takes stETH at deployment and compares to set threshold (10%)
contract AnteInstadappVaultPlungeTest is AnteTest("Instadapp Vault's stETH doesn't drop below 10% of its ETH at deployment") {
    // https://etherscan.io/address/0xa0d3707c569ff8c87fa923d3823ec5d81c98be78 
    address public constant iETHv2TokenAddress = 0xA0D3707c569ff8C87FA923d3823eC5D81c98Be78;

    IERC20 stETHToken = IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    // threshold amount for the test to fail
    uint256 public immutable threshold;

    /// @notice percent drop threshold (set to 10%)
    uint256 public constant PERCENT_DROP_THRESHOLD = 10;

    uint256 public immutable stETHBalanceAtDeploy;

    constructor() {
        protocolName = "Instadapp";
        testedContracts = [iETHv2TokenAddress];

        stETHBalanceAtDeploy = stETHToken.balanceOf(iETHv2TokenAddress);

        threshold = stETHBalanceAtDeploy * (PERCENT_DROP_THRESHOLD / 100);
    }

    /// @notice test to check balance of stETH 
    /// @return true if Instadapp Vault's stETH Escrow doesn't drop under 10% of the balance at the time of deployment
    function checkTestPasses() public view override returns (bool) {
        return (stETHToken.balanceOf(iETHv2TokenAddress) > threshold);
    }
}