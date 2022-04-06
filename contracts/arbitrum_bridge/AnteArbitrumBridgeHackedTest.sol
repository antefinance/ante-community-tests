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
    // https://etherscan.io/address/0xa3A7B6F88361F48403514059F1F16C8E78d60EeC
    address public constant ArbitrumBridgeAddr = 0xa3A7B6F88361F48403514059F1F16C8E78d60EeC;
    // https://etherscan.io/address/0xB0c7a3Ba49C7a6EaBa6cD4a96C55a1391070Ac9A
    address public constant magicAddr = 0xB0c7a3Ba49C7a6EaBa6cD4a96C55a1391070Ac9A;
    // https://etherscan.io/address/0xEec2bE5c91ae7f8a338e1e5f3b5DE49d07AfdC81
    address public constant dopexAddr = 0xEec2bE5c91ae7f8a338e1e5f3b5DE49d07AfdC81;
    // https://etherscan.io/address/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    address public constant wrappedAddr = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    // https://etherscan.io/address/0x97872EAfd79940C7b24f7BCc1EADb1457347ADc9
    address public constant stripsAddr = 0x97872EAfd79940C7b24f7BCc1EADb1457347ADc9;
    // https://etherscan.io/address/0x8df6606b8E624333EBEcce706edbf7139BDD56B1
    address public constant l2padAddr = 0x8df6606b8E624333EBEcce706edbf7139BDD56B1;

    IERC20 public magicToken;
    IERC20 public dopexToken;
    IERC20 public wrappedToken;
    IERC20 public stripsToken;
    IERC20 public l2padToken;

    uint256 public immutable magicBalanceAtDeploy;
    uint256 public immutable dopexBalanceAtDeploy;
    uint256 public immutable wrappedBalanceAtDeploy;
    uint256 public immutable stripsBalanceAtDeploy;
    uint256 public immutable l2padBalanceAtDeploy;

    constructor() {
        protocolName = "Arbitrum: Bridge";
        testedContracts = [ArbitrumBridgeAddr];

        magicToken = IERC20(magicAddr);
        dopexToken = IERC20(dopexAddr);
        wrappedToken = IERC20(wrappedAddr);
        stripsToken = IERC20(stripsAddr);
        l2padToken = IERC20(l2padAddr);

        magicBalanceAtDeploy = magicToken.balanceOf(ArbitrumBridgeAddr);
        dopexBalanceAtDeploy = dopexToken.balanceOf(ArbitrumBridgeAddr);
        wrappedBalanceAtDeploy = wrappedToken.balanceOf(ArbitrumBridgeAddr);
        stripsBalanceAtDeploy = stripsToken.balanceOf(ArbitrumBridgeAddr);
        l2padBalanceAtDeploy = l2padToken.balanceOf(ArbitrumBridgeAddr);
    }

    /// @notice test to check value of ether + top 5 tokens on Arbitrum Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return ((magicBalanceAtDeploy / 10) < magicToken.balanceOf(ArbitrumBridgeAddr) &&
            (dopexBalanceAtDeploy / 10) < dopexToken.balanceOf(ArbitrumBridgeAddr) &&
            (wrappedBalanceAtDeploy / 10) < wrappedToken.balanceOf(ArbitrumBridgeAddr) &&
            (stripsBalanceAtDeploy / 10) < stripsToken.balanceOf(ArbitrumBridgeAddr) &&
            (l2padBalanceAtDeploy / 10) < l2padToken.balanceOf(ArbitrumBridgeAddr));
    }
}
