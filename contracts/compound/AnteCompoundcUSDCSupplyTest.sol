// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

/// @title Ante Test to check Compund Finance cUSDC total supply never will be less than 8591273087904514301/(10^8) = 85 912 730 879
/// @dev Checks cUSDC totalSupply in Compound cUSDC contract

contract AnteCompoundcUSDCSupplyTest is AnteTest("cUSDC totalSupply is greater than 8591273087904514301") {
    // cUSDC Address: https://etherscan.io/token/0x39aa39c021dfbae8fac545936693ac917d5e7563

    address public immutable cusdcAddress;
    uint256 public immutable thresholdSupply;
    IERC20 public cusdcToken;

    constructor(address _cusdcAddress) {
        cusdcAddress = _cusdcAddress;
        cusdcToken = IERC20(_cusdcAddress);
        thresholdSupply = 8591273087904514301;

        protocolName = "Compound";
        testedContracts = [_cusdcAddress];
    }

    /// @notice test to check if cUSDC token supply is greater than 8591273087904514301
    /// @return true if supply is greater than 8591273087904514301
    function checkTestPasses() external view override returns (bool) {
        // Protocol Math: https://compound.finance/docs#protocol-math
        return (cusdcToken.totalSupply() >= thresholdSupply);
    }
}
