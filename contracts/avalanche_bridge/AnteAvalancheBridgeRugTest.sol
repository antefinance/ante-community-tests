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

/// @title Avalanche Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if EOA Avalanche Bridge "rugs" 99% of its ETH (as of Janurary 2022)
contract AnteAvalancheBridgeRugTest is AnteTest("EOA Avalanche Bridge Doesnt Rug 99% of its ETH Test") {
    // https://etherscan.io/address/0xE78388b4CE79068e89Bf8aA7f218eF6b9AB0e9d0
    address public constant eoaAvalancheBridgeAddr = 0xE78388b4CE79068e89Bf8aA7f218eF6b9AB0e9d0;

    // 2022-01-11: Avalanche Bridge has approx. 200 - 230 ETH, so -99% is ~2 ETH
    uint256 public constant RUG_THRESHOLD = 2 * 1e18;

    constructor() {
        protocolName = "Avalanche: Bridge";
        testedContracts = [eoaAvalancheBridgeAddr];
    }

    /// @notice test to check balance of Avalanche Bridge
    /// @return true if bridge has over 2000 ETH
    function checkTestPasses() external view override returns (bool) {
        return eoaAvalancheBridgeAddr.balance >= RUG_THRESHOLD;
    }

    function bridgeBalance() external view returns (uint256) {
        return eoaAvalancheBridgeAddr.balance / (1 ether);
    }
}
