// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks RBN balance of Ribbon multisig remains >= 1m
/// @notice Ante Test to check if Ribbon multisig has been hacked or rugged
contract AnteRibbonMultisigRBNTest is AnteTest("Ribbon Multisig RBN balance remains >=1m") {
    // https://etherscan.io/address/0xdaeada3d210d2f45874724beea03c7d4bbd41674
    address public constant RIBBON_MULTISIG = 0xDAEada3d210D2f45874724BeEa03C7d4BBD41674;
    // https://etherscan.io/address/0x6123B0049F904d730dB3C36a31167D9d4121fA6B
    IERC20Metadata public constant RBN = IERC20Metadata(0x6123B0049F904d730dB3C36a31167D9d4121fA6B);
    // set to 1 million RBN
    uint256 public immutable thresholdBalance;

    constructor() {
        thresholdBalance = (1000 * 1000) * (10**RBN.decimals());

        protocolName = "Ribbon";
        testedContracts = [address(RBN), RIBBON_MULTISIG];
    }

    /// @notice test to check if RBN balance in Ribbon Multisig is >=1m
    /// @return true if RBN balance in Ribbon Multisig is >=1m
    function checkTestPasses() public view override returns (bool) {
        return (RBN.balanceOf(RIBBON_MULTISIG) >= thresholdBalance);
    }
}
