// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";


/// @title Ante Uniswap Get Reserves
/// @notice Ensures that getReserves returns a value that makes sense 
contract AnteUniswapGetReservesTest is AnteTest("Ensure that getReserves returns a reasonable value") {

    AggregatorV3Interface private immutable priceFeed;
    IUniswapV2Pair private uniswapPair;

    uint256 private immutable decimals0;
    uint256 private immutable decimals1;
    address private immutable chainLinkOracle;

    uint256 private lastCheckBlock = 0;
    int256 private lastCheckPercentage = 0;

    /// @param _uniswapPair The Uniswap pair to test.
    /// @param _chainLinkOracle price feed to use.
    /// @notice The Chainlink order should be expensive currency -> cheaper currency. 
    /// Eg ETH/USD and not the other way around
    constructor(address _uniswapPair, address _chainLinkOracle ) {
        protocolName = "Uniswap";

        testedContracts = [_uniswapPair];
        chainLinkOracle = _chainLinkOracle;

        priceFeed = AggregatorV3Interface(_chainLinkOracle);
        uniswapPair = IUniswapV2Pair(_uniswapPair);

        decimals0 = IERC20(uniswapPair.token0()).decimals();
        decimals1 = IERC20(uniswapPair.token1()).decimals();
    }

    /// @notice Pre-calls the function as a flash loan attack prevention
    function preCall() public {
        (uint112 reserve0, uint112 reserve1,) = uniswapPair.getReserves();
        (, int256 price, , ,) = priceFeed.latestRoundData();

        lastCheckBlock = block.number;
        lastCheckPercentage = calculatePercentage(reserve0, reserve1, price, decimals0, decimals1);
    }

    /// @notice Test must be called 2 to 50 block after the preCall
    /// @return true if getReserves returns a reasonable value within 20%
    function checkTestPasses() public view override returns (bool) {
        (uint112 reserve0, uint112 reserve1,) = uniswapPair.getReserves();
        (, int256 price, , ,) = priceFeed.latestRoundData();

        // Need to make sure that the preCheck() function was called before this function
        // If not, then the test reverts to true.
        if (block.number == 0 || block.number - lastCheckBlock > 50 || block.number - lastCheckBlock < 1 || lastCheckPercentage == 0) {
            return true;
        }

        if (lastCheckPercentage < 80 && calculatePercentage(reserve0, reserve1, price, decimals0, decimals1) < 80) {
            return false;
        }

        return true;
    }

    /// @notice Calculates the percentage difference between the reserves ratio and respective price
    /// @param reserve0 The first token
    /// @param reserve1 The second token
    /// @param price The price of reserve1:reserve0
    /// @param _decimal0 The decimals of reserve0
    /// @param _decimal1 The decimals of reserve1
    function calculatePercentage(uint112 reserve0, uint112 reserve1, int256 price, uint256 _decimal0, uint256 _decimal1) public pure returns(int256) {

        // Get lowest decimal and adjust for decimal difference
        if(_decimal0 < _decimal1) {
            uint256 decimalDifference = _decimal1 - _decimal0;
            reserve1 = reserve1 / uint112(10**decimalDifference);
        } else if(_decimal0 > _decimal1) {
            uint256 decimalDifference = _decimal0 - _decimal1;
            reserve0 = reserve0 / uint112(10**decimalDifference);
        }
        
        // Swap so that reserve 1 is always bigger than reserve 0
        if (reserve0 > reserve1) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }

        // A ratio of 2.3 would be 230
        uint256 unsignedRatio = uint256((reserve1 * 100) / reserve0);
        int256 reserveRatio = int256(unsignedRatio);

        price = price * 100;
        price = price / 10e7; // Chainlink uses 8 decimals  

        return (price * 100) / reserveRatio;
    }
}
