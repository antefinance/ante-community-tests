// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Instadapp Treasury Token Balance Test
/// @notice Ante Test to check if Instadapp Treasury maintains a total balance greater than
///          2 million INST tokens
contract AnteInstadappTreasuryBalanceTest is AnteTest("Instadapp Treasury Balance greater than 2 million") {
    
    address public constant tokenAddr = 0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb;
    address public constant treasuryAddr = 0x28849D2b63fA8D361e5fc15cB8aBB13019884d09;

    IERC20Metadata public INST = IERC20Metadata(tokenAddr);

    uint256 public immutable thresholdBalance;

    constructor() {
        protocolName = "Instadapp";
        testedContracts = [treasuryAddr];
        thresholdBalance = 2e6;
    }

    /// @return thresholdBalance adjusted with decimals
    function getThresholdBalance() public view returns (uint256) {
        return thresholdBalance * 10**INST.decimals();
    }

    /// @return Instadapp Treasury INST token Balance with decimals
    function getTreasuryBalance() public view returns (uint256) {
        return INST.balanceOf(treasuryAddr);
    }

    /// @return true if the Instadapp Treasury INST balance is > 2 million
    function checkTestPasses() public view override returns (bool) {
        return getTreasuryBalance() > thresholdBalance;
    }
}
