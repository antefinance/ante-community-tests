// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

// @title Ensure that the slippage of these two tokens are <= 3%
contract AnteUSDTUSTSlippage is AnteTest("Ante UST-USDT Slippage Test on Uniswap") {
    // https://etherscan.io/token/0xc50Ef7861153C51D383d9a7d48e6C9467fB90c38
    address public constant USDT_UST_Pair = 0xc50Ef7861153C51D383d9a7d48e6C9467fB90c38;

    constructor() {
        protocolName = "Uniswap";
        testedContracts = [USDT_UST_Pair];
    }

    // @return reserve0 and reserve1 from the uniswap pair
    // @notice Will only work on mainnet
    function getTokenPrice() public view returns(uint112, uint112) {
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(USDT_UST_Pair);

        (uint112 x, uint112 y,) = uniswapPair.getReserves();

        // x and y may be different values but not because of slippage.
        // The number 12 comes from the decimal difference.
        // To find the decimals, lookup the token on etherscan
        for(uint8 i = 0; i < 12; i++) {
            x = x / 10;
        }

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