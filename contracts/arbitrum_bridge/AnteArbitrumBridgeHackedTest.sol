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
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

/// @title Arbitrum Bridge Doesn't Get Hacked
/// @notice Ante Test to check if Arbitrum Bridge Doesn't Get Hacked (as of test deployment)
contract AnteArbitrumBridgeHackedTest is AnteTest("Arbitrum Bridge Doesn't Get Hacked") {
    // https://etherscan.io/address/0x011b6e24ffb0b5f5fcc564cf4183c5bbbc96d515
    address public constant ArbitrumBridgeAddr = 0x011B6E24FfB0B5f5fCc564cf4183C5BBBc96D515;
    // https://etherscan.io/address/0x06a87F6aFEc4a739c367bEF69eEfE383D27106bd
    address public constant scoobiAddr = 0x06a87F6aFEc4a739c367bEF69eEfE383D27106bd;
    // https://etherscan.io/address/0x2eE543b8866F46cC3dC93224C6742a8911a59750
    address public constant mvdgAddr = 0x2eE543b8866F46cC3dC93224C6742a8911a59750;
    // https://etherscan.io/address/0x89C81D3725EB9e1D4aE21082865D1653E10EaE1b
    address public constant evmosAddr = 0x89C81D3725EB9e1D4aE21082865D1653E10EaE1b;
    // https://etherscan.io/address/0xca8a414F170Bc635f7Bb21aF7951922fa33A82B0
    address public constant lzeroAddr = 0xca8a414F170Bc635f7Bb21aF7951922fa33A82B0;

    IERC20 public scoobiToken;
    IERC20 public mvdgToken;
    IERC20 public evmosToken;
    IERC20 public lzeroToken;

    uint256 public immutable etherBalanceAtDeploy;
    uint256 public immutable scoobiBalanceAtDeploy;
    uint256 public immutable mvdgBalanceAtDeploy;
    uint256 public immutable evmosBalanceAtDeploy;
    uint256 public immutable lzeroBalanceAtDeploy;

    constructor() {
        protocolName = "Arbitrum: Bridge";
        testedContracts = [ArbitrumBridgeAddr];

        scoobiToken = IERC20(scoobiAddr);
        mvdgToken = IERC20(mvdgAddr);
        evmosToken = IERC20(evmosAddr);
        lzeroToken = IERC20(lzeroAddr);

        etherBalanceAtDeploy = ArbitrumBridgeAddr.balance;
        scoobiBalanceAtDeploy = scoobiToken.balanceOf(ArbitrumBridgeAddr);
        mvdgBalanceAtDeploy = mvdgToken.balanceOf(ArbitrumBridgeAddr);
        evmosBalanceAtDeploy = evmosToken.balanceOf(ArbitrumBridgeAddr);
        lzeroBalanceAtDeploy = lzeroToken.balanceOf(ArbitrumBridgeAddr);
    }

    /// @notice test to check value of ether + top 5 tokens on Arbitrum Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return ((etherBalanceAtDeploy / 10) < ArbitrumBridgeAddr.balance &&
            (scoobiBalanceAtDeploy / 10) < scoobiToken.balanceOf(ArbitrumBridgeAddr) &&
            (mvdgBalanceAtDeploy / 10) < mvdgToken.balanceOf(ArbitrumBridgeAddr) &&
            (evmosBalanceAtDeploy / 10) < evmosToken.balanceOf(ArbitrumBridgeAddr) &&
            (lzeroBalanceAtDeploy / 10) < lzeroToken.balanceOf(ArbitrumBridgeAddr));
    }
}
