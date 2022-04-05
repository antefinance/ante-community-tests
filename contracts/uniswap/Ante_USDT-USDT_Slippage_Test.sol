// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

// @title Ensure that the slippage of these two tokens are <= 3%
contract AnteUSDCUSDTPeg is AnteTest("Ante USDC-USDT Slippage Test on Uniswap") {
    // https://etherscan.io/token/0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f
    address public constant USDT_USDC_Pair = 0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f;

    constructor() {
        protocolName = "Uniswap";
        testedContracts = [USDT_USDC_Pair];
    }
    
    // @return reserve0 and reserve1 from the uniswap pair
    // @notice Will only work on mainnet
    function getTokenPrice() private view returns(uint112, uint112) {
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(USDT_USDC_Pair);

        (uint112 x, uint112 y,) = uniswapPair.getReserves();

        // Always make sure that the percentage will be equal to or less than 100
        if(x > y) {
            (x, y) = (y, x); // More gas efficient swap compared to using a temp var
        }
        return (x, y);
    }

    // @return bool if the price difference is >= 3%
    function checkTestPasses() public view override returns (bool) {
        (uint112 x, uint112 y) = getTokenPrice();

        return(100 * x / y >= 97);
    }
}