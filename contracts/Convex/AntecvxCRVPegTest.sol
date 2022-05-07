// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface IOneInchOracle {
    function getRate(address srcToken, address dstToken, bool useWrapper) external view returns(uint256);
}

/// @title Convex Curve Peg Test
/// @notice The 1inch Oracle is unable to accurately price the two currencies to each other
/// to get around this, we use the ETH exchange rate and compare the two.
contract AntecvxCRVPegTest is AnteTest("Curve stETH Keeps 99% of it's ETH.") {
    IOneInchOracle private oneInchOracle = IOneInchOracle(0x07D91f5fb9Bf7798734C3f606dB065549F6893bb);

    address private constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant CURVE_ADDRESS = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant CVX_CURVE_ADDRESS = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;

    uint256 public preCheckBlock = 0;
    uint256 public preCheckSlip = 0;

    constructor() {
        protocolName = "Convex";
        testedContracts = [CURVE_ADDRESS, CVX_CURVE_ADDRESS];
    }

    /// @notice Used to prevent flash loan attacks
    function preCheck() external {
        uint256 crvToETH = oneInchOracle.getRate(CURVE_ADDRESS, WETH_ADDRESS, false);
        uint256 cvxCRVToETH = oneInchOracle.getRate(CVX_CURVE_ADDRESS, WETH_ADDRESS, false);

        preCheckBlock = block.number;
        preCheckSlip = (crvToETH * 100) / cvxCRVToETH;
    }

    /// @notice Must be called after 20 blocks after preCheck()
    /// @return true if the peg is within 4%
    function checkTestPasses() external view override returns (bool) {
        uint256 crvToETH = oneInchOracle.getRate(CURVE_ADDRESS, WETH_ADDRESS, false);
        uint256 cvxCRVToETH = oneInchOracle.getRate(CVX_CURVE_ADDRESS, WETH_ADDRESS, false);

        if(preCheckBlock == 0 || preCheckSlip == 0) {
            return true;
        }

        if (block.number - preCheckBlock < 20 ) {
            return true;
        }

        uint256 slip = (crvToETH * 100) / cvxCRVToETH;

        // If each slippage test was within 10% of the preCheckSlip, then the test passes
        if ((slip < 105 && slip > 95) && (preCheckSlip < 105 && preCheckSlip > 95)) {
            return true;
        }

        return false;
    }   
}
