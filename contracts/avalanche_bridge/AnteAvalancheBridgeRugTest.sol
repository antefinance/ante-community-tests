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

/// @title Avalanche Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if EOA Avalanche Bridge "rugs" 99% of its value (as of test deployment)
contract AnteAvalancheBridgeRugTest is AnteTest("EOA Avalanche Bridge Doesnt Rug 99% of its Value Test") {
    // https://etherscan.io/address/0x8eb8a3b98659cce290402893d0123abb75e3ab28
    address public constant eoaAvalancheBridgeAddr = 0x8EB8a3b98659Cce290402893d0123abb75E3ab28;
    // https://etherscan.io/address/0x6B175474E89094C44Da98b954EedeAC495271d0F
    address public constant daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    address public constant wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // https://etherscan.io/address/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    address public constant wbtcAddr = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    // https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address public constant tetherAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 public daiToken;
    IERC20 public wethToken;
    IERC20 public usdcToken;
    IERC20 public wbtcToken;
    IERC20 public tetherToken;

    uint256 public immutable etherBalanceAtDeploy;
    uint256 public immutable daiBalanceAtDeploy;
    uint256 public immutable wethBalanceAtDeploy;
    uint256 public immutable usdcBalanceAtDeploy;
    uint256 public immutable wbtcBalanceAtDeploy;
    uint256 public immutable tetherBalanceAtDeploy;

    constructor() {
        protocolName = "Avalanche: Bridge";
        testedContracts = [eoaAvalancheBridgeAddr];

        daiToken = IERC20(daiAddr);
        wethToken = IERC20(wethAddr);
        usdcToken = IERC20(usdcAddr);
        wbtcToken = IERC20(wbtcAddr);
        tetherToken = IERC20(tetherAddr);

        etherBalanceAtDeploy = eoaAvalancheBridgeAddr.balance;
        daiBalanceAtDeploy = daiToken.balanceOf(eoaAvalancheBridgeAddr);
        wethBalanceAtDeploy = wethToken.balanceOf(eoaAvalancheBridgeAddr);
        usdcBalanceAtDeploy = usdcToken.balanceOf(eoaAvalancheBridgeAddr);
        wbtcBalanceAtDeploy = wbtcToken.balanceOf(eoaAvalancheBridgeAddr);
        tetherBalanceAtDeploy = tetherToken.balanceOf(eoaAvalancheBridgeAddr);
    }

    /// @notice test to check value of ether + top 5 tokens on Avalanche Bridge is not rugged
    /// @return true if bridge has more than 1% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return ((etherBalanceAtDeploy / 100) < eoaAvalancheBridgeAddr.balance &&
            (daiBalanceAtDeploy / 100) < daiToken.balanceOf(eoaAvalancheBridgeAddr) &&
            (wethBalanceAtDeploy / 100) < wethToken.balanceOf(eoaAvalancheBridgeAddr) &&
            (usdcBalanceAtDeploy / 100) < usdcToken.balanceOf(eoaAvalancheBridgeAddr) &&
            (wbtcBalanceAtDeploy / 100) < wbtcToken.balanceOf(eoaAvalancheBridgeAddr) &&
            (tetherBalanceAtDeploy / 100) < tetherToken.balanceOf(eoaAvalancheBridgeAddr));
    }
}
