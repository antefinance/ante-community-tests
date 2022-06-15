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

/// @title Axie Ronin Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if Axie Ronin Bridge "rugs" 90% of its value (as of test deployment)
contract AnteAxieRoninBridgeRugTest is AnteTest("Axie Ronin Bridge Doesnt Rug 90% of its Value") {
    address public constant RONIN_BRIDGE = 0x1A2a1c938CE3eC39b6D47113c7955bAa9DD454F2;

    IERC20 private constant AXS = IERC20(0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b);
    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 private constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint256 public constant THRESHOLD = 10;

    uint256 public immutable ethThreshold;
    uint256 public immutable axsThreshold;
    uint256 public immutable usdcThreshold;
    uint256 public immutable wethThreshold;

    constructor() {
        protocolName = "Axie Infinity";
        testedContracts = [RONIN_BRIDGE];

        ethThreshold = (RONIN_BRIDGE.balance * THRESHOLD) / 100;
        axsThreshold = (AXS.balanceOf(RONIN_BRIDGE) * THRESHOLD) / 100;
        wethThreshold = (WETH.balanceOf(RONIN_BRIDGE) * THRESHOLD) / 100;
        usdcThreshold = (USDC.balanceOf(RONIN_BRIDGE) * THRESHOLD) / 100;
    }

    /// @notice test to check value of ether + top 4 tokens on Ronin Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return
            ethThreshold < RONIN_BRIDGE.balance &&
            axsThreshold < AXS.balanceOf(RONIN_BRIDGE) &&
            wethThreshold < WETH.balanceOf(RONIN_BRIDGE) &&
            usdcThreshold < USDC.balanceOf(RONIN_BRIDGE);
    }
}
