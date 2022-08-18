// SPDX-License-Identifier: GPL-3.0-only


pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

/// @title Polygon Bridge doesn't rug test on mainnet
/// @notice Ante Test to check if EOA Polygon Bridge "rugs" 90% of its value (as of test deployment)
contract AntePolygonBridgeRugTest is AnteTest("EOA Polygon Bridge Doesnt Rug 90% of its Value Test") {
   
    // https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // https://etherscan.io/address/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0
    address public constant maticAddr = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
    // https://etherscan.io/address/0xd26114cd6EE289AccF82350c8d8487fedB8A0C07
    address public constant omgAddr = 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07;
    // https://etherscan.io/address/0xa0c68c638235ee32657e8f720a23cec1bfc77c77
    address public constant eoaPolygonBridgeAddr = 0xa0c68c638235ee32657e8f720a23cec1bfc77c77;
    IERC20 public usdcToken;
    IERC20 public omgToken;
    IERC20 public maticToken;

    uint256 public immutable usdcBalanceAtDeploy;
    uint256 public immutable omgBalanceAtDeploy;
    uint256 public immutable maticBalanceAtDeploy;

    constructor() {
        protocolName = "Polygon: Bridge";
        testedContracts = [eoaPolygonBridgeAddr];

        usdcToken = IERC20(usdcAddr);
        omgToken = IERC20(omgAddr);
        maticToken = IERC20(maticAddr);

        usdcBalanceAtDeploy = usdcToken.balanceOf(eoaPolygonBridgeAddr);
        maticBalanceAtDeploy = maticToken.balanceOf(eoaPolygonBridgeAddr);
        omgBalanceAtDeploy = omgToken.balanceOf(eoaPolygonBridgeAddr);
    }

    /// @notice test to check value of ether + top 3 tokens on Polygon Bridge is not rugged
    /// @return true if bridge has more than 10% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return (
            (usdcBalanceAtDeploy / 10) < usdcToken.balanceOf(eoaPolygonBridgeAddr) &&
            (maticBalanceAtDeploy / 10) < maticToken.balanceOf(eoaPolygonBridgeAddr) &&
            (omgBalanceAtDeploy / 10) < omgToken.balanceOf(eoaPolygonBridgeAddr)
        );
    }
}
