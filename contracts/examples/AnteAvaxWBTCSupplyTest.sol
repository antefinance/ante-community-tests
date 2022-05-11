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

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AnteTest} from "../AnteTest.sol";

/// @title WBTC.e supply never exceeds 21 million test
/// @notice Ante Test to check that WBTC.e supply is always less than 21 million
contract AnteAvaxWBTCSupplyTest is AnteTest("Wrapped BTC (WBTC.e) supply doesn't exceed 21m") {
    // https://snowtrace.io/address/0x50b7545627a5162f82a992c33b87adc75187b218
    address public immutable wBTCAddr;

    // 21 million, maximum total Bitcoin supply
    uint256 public constant THRESHOLD_SUPPLY = 21 * 1000 * 1000;

    IERC20Metadata public wBTCToken;

    /// @param _wBTCAddr WBTC.e contract address (0x50b7545627a5162F82A992c33b87aDc75187B218
    ///                  on avalanche c-chain)
    constructor(address _wBTCAddr) {
        protocolName = "WBTC";
        testedContracts = [_wBTCAddr];

        wBTCAddr = _wBTCAddr;
        wBTCToken = IERC20Metadata(_wBTCAddr);
    }

    /// @notice test to check WBTC token supply
    /// @return true if WBTC supply is less than 21 million
    function checkTestPasses() external view override returns (bool) {
        return (wBTCToken.totalSupply() <= THRESHOLD_SUPPLY * wBTCToken.decimals());
    }
}
