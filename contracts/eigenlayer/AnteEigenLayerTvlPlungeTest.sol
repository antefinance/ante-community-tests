// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title EigenLayerTvlPlungeTest
// @notice Ante Test that fails when any one of EigenLayer's cbETH, stETH, or rETH balances drop below -90% from this Ante Test deployment
contract AnteEigenLayerTvlPlungeTest is AnteTest("EigenLayer cbETH, stETH, rETH balances do NOT drop -90% from this Ante Test deployment") {
    
    address public constant EL_cbETH_STRATEGY_ADDR = 0x54945180dB7943c0ed0FEE7EdaB2Bd24620256bc;
    address public constant EL_stETH_STRATEGY_ADDR = 0x93c4b944D05dfe6df7645A86cd2206016c51564D;
    address public constant EL_rETH_STRATEGY_ADDR = 0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2;
    address public constant CBETH_TOKEN_ADDR = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
    address public constant STETH_TOKEN_ADDR = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant RETH_TOKEN_ADDR = 0xae78736Cd615f374D3085123A210448E74Fc6393;

    IERC20 public constant cbETH_TOKEN = IERC20(CBETH_TOKEN_ADDR);
    IERC20 public constant stETH_TOKEN = IERC20(STETH_TOKEN_ADDR);
    IERC20 public constant rETH_TOKEN = IERC20(RETH_TOKEN_ADDR);

    /// Thresholds
    uint256 public constant PERCENT_REDUCTION_TH = 90;
    uint256 public immutable cbETH_TH;
    uint256 public immutable stETH_TH;
    uint256 public immutable rETH_TH;

    constructor() {
        protocolName = "EigenLayer";
        testedContracts = [
            EL_cbETH_STRATEGY_ADDR, 
            EL_stETH_STRATEGY_ADDR, 
            EL_rETH_STRATEGY_ADDR
        ];
        cbETH_TH = cbETH_TOKEN.balanceOf(EL_cbETH_STRATEGY_ADDR) * 100 * (100 - PERCENT_REDUCTION_TH) / 10000;
        stETH_TH = stETH_TOKEN.balanceOf(EL_stETH_STRATEGY_ADDR) * 100 * (100 - PERCENT_REDUCTION_TH) / 10000;
        rETH_TH = rETH_TOKEN.balanceOf(EL_rETH_STRATEGY_ADDR) * 100 * (100 - PERCENT_REDUCTION_TH) / 10000;
    }

    /// @notice test to check if EigenLayer's cbETH, stETH, and rETH balances have not dropped below -90% from this Ante Test's deployment
    /// @return false if any one of EigenLayer's cbETH, stETH, or rETH balances are below -90% from this Ante Test's deployment
    function checkTestPasses() public view override returns (bool) {
        if (
            cbETH_TOKEN.balanceOf(EL_cbETH_STRATEGY_ADDR) <= cbETH_TH ||
            stETH_TOKEN.balanceOf(EL_stETH_STRATEGY_ADDR) <= stETH_TH ||
            rETH_TOKEN.balanceOf(EL_rETH_STRATEGY_ADDR) <= rETH_TH
        ) {
            return false;
        }
        else return true;
    }
}
