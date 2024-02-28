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

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";

/// @title SPELL supply never exceeds 420 billion test and 210 billion SPELL has been burned
/// @notice Ante Test to check that SPELL supply is always less than 420 billion and 210 billion SPELL has been burned
contract AnteSPELLSupplyTest is AnteTest("SPELL supply doesn't exceed 21b") {
    // https://etherscan.io/address/0x090185f2135308bad17527004364ebcc2d37e5f6
    address public immutable SPELLAddr;

    //420 billion * 1e27 (for decimals), maximum total SPELL supply
    uint256 public constant THRESHOLD_SUPPLY = 420 * 1e27;

    //210 billion * 1e27 (for decimals), SPELL that has been burned
    uint256 public constant BURNED_SUPPLY = 210 * 1e27;

    IERC20 public SPELLToken;

    /// @param _SPELLAddr SPELL contract address (0x090185f2135308bad17527004364ebcc2d37e5f6 on mainnet)
    constructor(address _SPELLAddr) {
        protocolName = "SPELL";
        testedContracts = [_SPELLAddr];

        SPELLAddr = _SPELLAddr;
        SPELLToken = IERC20(_SPELLAddr);
    }

    /// @notice test to check SPELL token supply
    /// @return true if SPELL supply is less than 420 billion and more than 210 billion SPELL has been burned by being sent to the smart contract
    function checkTestPasses() public view override returns (bool) {
        return (SPELLToken.totalSupply() <= THRESHOLD_SUPPLY && SPELLToken.balanceOf(SPELLAddr) >= BURNED_SUPPLY);
    }
}
