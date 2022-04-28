// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

/// @title Curve 3Pool Balance Test
/// @notice Ensure that at least 2 of three tokens are balanced within 25% of each other
/// @dev At different times, there will be different trading volume for each pair
/// based on interest. For example, 1 year ago, USDT was balanced within 15% of the others
/// and now it only makes up half compared to another token in the pool.
/// Based on three time points; today, 6 months ago, and 1 year ago, the highest variation was
/// 20%. Based on this, the threshold will be a 25% difference.
/// Eg (100, 120, 60) will pass and (100, 150, 60) will fail
contract AnteThreePoolBalanceTest is AnteTest("Ensure that curve keeps a TVL of > 10%") {

    address private constant CURVE_THREE_POOL_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address private constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IERC20 private constant USDC = IERC20(USDC_ADDRESS);
    IERC20 private constant USDT = IERC20(USDT_ADDRESS);
    IERC20 private constant DAI = IERC20(DAI_ADDRESS);

    constructor() {
        testedContracts = [CURVE_THREE_POOL_ADDRESS];
        protocolName = "Curve";
    }

    /// @return if one pair is balanced within 25% of the other
    function checkTestPasses() public view override returns (bool) {
        return isBalanced
        (
            USDC.balanceOf(CURVE_THREE_POOL_ADDRESS), 
            USDT.balanceOf(CURVE_THREE_POOL_ADDRESS), 
            DAI.balanceOf(CURVE_THREE_POOL_ADDRESS) / 1e12 // DAI has 18 decimals, so divide to reduce to 6
        ); 
    }

    /// @dev Function used for unit testing to ensure the input and output is correct
    /// @param usdc The amount of USDC in the pool
    /// @param usdt The amount of USDT in the pool
    /// @param dai The amount of DAI in the pool
    /// @return true if at least one of the pairs are balanced within 25% of each other
    function isBalanced(uint256 usdc, uint256 usdt, uint256 dai) public pure returns(bool) {
        uint256 usdcusdt = usdc < usdt ?  (usdc*100) / usdt : (usdt*100) / usdc;
        uint256 usdcdai  = usdc < dai  ?  (usdc*100) / dai  : (dai*100)  / usdc;
        uint256 usdtdai  = usdt < dai  ?  (usdt*100) / dai  : (dai*100)  / usdt;

        return usdcusdt > 75 || usdcdai > 75 || usdtdai > 75;
    }
}
