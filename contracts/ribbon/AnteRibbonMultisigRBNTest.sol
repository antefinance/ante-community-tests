// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Ante Test to check if Ribbon Multisig keeps at least 1m out of >141m RBN as of 20220308
contract AnteRibbonMultisigRBNTest is AnteTest("Ribbon Multisig RBN balance remains >=1m") {
    // https://etherscan.io/address/0xdaeada3d210d2f45874724beea03c7d4bbd41674
    address public constant ribbonMultisigAddr = 0xDAEada3d210D2f45874724BeEa03C7d4BBD41674;
    address public immutable rbnTokenAddr;
    uint256 public immutable thresholdBalance;

    ERC20 public rbnToken;

    /// @param _rbnTokenAddr $RBN contract addr (0x6123B0049F904d730dB3C36a31167D9d4121fA6B on mainnet)
    constructor(address _rbnTokenAddr) {
        rbnTokenAddr = _rbnTokenAddr;
        rbnToken = ERC20(_rbnTokenAddr);
        thresholdBalance = (1000 * 1000) * (10**rbnToken.decimals());

        protocolName = "Ribbon";
        testedContracts = [_rbnTokenAddr, ribbonMultisigAddr];
    }

    /// @notice test to check if RBN balance in Ribbon Multisig is >=1m
    /// @return true if RBN balance in Ribbon Multisig is >=1m
    function checkTestPasses() public view override returns (bool) {
        return (rbnToken.balanceOf(ribbonMultisigAddr) >= thresholdBalance);
    }
}
