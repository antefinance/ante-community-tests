// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";  

interface IOneInchOracle {
    function getRateToEth(address srcToken, bool useWrapper) external view returns(uint256);
}

/// @title Curve Pool CRV x cvxCRV Reserve Balance Test
/// @notice Ensures that the balance of each asset is no greater than 30% the other's
/// and the reserve difference is according the the price difference
contract AnteConvexCRVPoolBalanceTest is AnteTest("Curve stETH Keeps 99% of it's ETH.") {
    // https://curve.fi/factory/22
    address constant private CURVE_POOL = 0x9D0464996170c6B9e75eED71c68B99dDEDf279e8;

    address private constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant CURVE_ADDRESS = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant CVX_CURVE_ADDRESS = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;

    IERC20 private constant CURVE_TOKEN = IERC20(CURVE_ADDRESS);
    IERC20 private constant CVX_CURVE_TOKEN = IERC20(CVX_CURVE_ADDRESS);

    // https://docs.1inch.io/docs/spot-price-aggregator/introduction/
    IOneInchOracle private oneInchOracle = IOneInchOracle(0x07D91f5fb9Bf7798734C3f606dB065549F6893bb);

    constructor() {
        protocolName = "Curve";
        testedContracts = [CURVE_POOL];
    }

    /// @return true if the reserve difference is according the the price difference
    function checkTestPasses() external view override returns (bool) {
        address strongerCurrency = getStrongerCurrency(CURVE_ADDRESS, CVX_CURVE_ADDRESS);

        if (strongerCurrency == address(0)) {
            return true;
        }

        if (getPriceSlip() > 130 || getPriceSlip() < 70) {
            return false;
        }

        // There should be less curve than cvx curve
        if (strongerCurrency == CURVE_ADDRESS) {
            return CURVE_TOKEN.balanceOf(CURVE_POOL) <= CVX_CURVE_TOKEN.balanceOf(CURVE_POOL);
        }

        // There should be more curve than cvx curve
        if (strongerCurrency == CVX_CURVE_ADDRESS) {
            return CURVE_TOKEN.balanceOf(CURVE_POOL) >= CVX_CURVE_TOKEN.balanceOf(CURVE_POOL);
        }

        return false;
    }

    /// @return percentage price slip
    function getPriceSlip() public view returns (uint256) {
        uint256 crvToETH = oneInchOracle.getRateToEth(CURVE_ADDRESS, false);
        uint256 cvxCRVToETH = oneInchOracle.getRateToEth(CVX_CURVE_ADDRESS, false);

        return (crvToETH * 100) / cvxCRVToETH;
    }

    /// @notice Gets the stronger currency (eg ETH is stronger than USDC)
    /// @param token1 The first currency
    /// @param token2 The second currency
    /// @return The stronger currency
    function getStrongerCurrency(address token1, address token2) public view returns (address) {
        IERC20 token1Instance = IERC20(token1);
        IERC20 token2Instance = IERC20(token2);

        uint256 decimalsToken1 = token1Instance.decimals();
        uint256 decimalsToken2 = token2Instance.decimals();
        uint256 decimalDifference = 0;

        uint256 valueToken1 = oneInchOracle.getRateToEth(token1, false);
        uint256 valueToken2 = oneInchOracle.getRateToEth(token2, false);

        if(decimalsToken1 > decimalsToken2) {
            decimalDifference = decimalsToken1 - decimalsToken2;
            valueToken1 = valueToken1 / (10 ** decimalDifference);
        } else {
            decimalDifference = decimalsToken2 - decimalsToken1;
            valueToken2 = valueToken2 / (10 ** decimalDifference);
        }

        if (valueToken1 == valueToken2) { return address(0); }
        if (valueToken1 > valueToken2)  { return token1; } 

        return token2;
    }
}
