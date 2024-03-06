// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";

/// @title Blast's ETHYieldManager contract doesn't rug on mainnet, this is the final contract the bridged ETH goes to
/// @author 0x11d1f1945414B60c4aC9e850dfD7bEB6B153d128
/// @notice Ante test takes ETH at deployment and compares to set threshold (10%)
contract AnteBlastETHYieldManagerPlungeTest is AnteTest("Blast ETHYieldManager doesn't drop under 10% of its ETH") {
    // https://etherscan.io/address/0x98078db053902644191f93988341e31289e1c8fe
    address public constant blastETHYieldManagerAddress= 0x98078db053902644191f93988341E31289E1C8FE;

    // threshold amount for the test to fail
    uint256 public immutable threshold;

    /// @notice percent drop threshold (set to 10%)
    uint256 public constant PERCENT_DROP_THRESHOLD = 10;

    uint256 public immutable etherBalanceAtDeploy;

    constructor() {
        protocolName = "Blast";
        testedContracts = [blastETHYieldManagerAddress];

        etherBalanceAtDeploy = blastETHYieldManagerAddress.balance;

        threshold = etherBalanceAtDeploy * (PERCENT_DROP_THRESHOLD / 100);
    }

    /// @notice test to check balance of eth
    /// @return true if ETHYieldManager doesn't drop under 10% of the balance at the time of deployment
    function checkTestPasses() public view override returns (bool) {
        return (blastETHYieldManagerAddress.balance > threshold);
    }
}
