// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./interfaces/IPendleMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Ante Test to check if the weight of xyt and token add up to 2^40,
/// xyt weight should be less than or equal to token weight
contract AntePendleMarketWeightTest is AnteTest("Pendle Market Weight Test") {
    address[4] public markets = [
        0x8315BcBC2c5C1Ef09B71731ab3827b0808A2D6bD, // YT-aUSDC/USDC_Dec_29_2022
        0xB26C86330FC7F97533051F2F8cD0a90C2E82b5EE, // YT-cDai/USDC_Dec_29_2022
        0x79c05Da47dC20ff9376B2f7DbF8ae0c994C3A0D0, // YT-ETHUSDC/USDC_Dec_29_2022
        0x685d32f394a5F03e78a1A0F6A91B4E2bf6F52cfE // YT-PENDLEETH/PENDLE_Dec_29_2022
    ];

    uint256 public constant RONE = 1 << 40;

    constructor() {
        protocolName = "Pendle";

        for (uint256 i = 0; i < markets.length; ++i) {
            testedContracts.push(markets[i]);
        }
    }

    /// @notice check reserve data weight of xyt and token
    /// @return true if xytWeight is smaller than or equal to tokenWeight, and they add up to 2^40
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < markets.length; ++i) {
            IPendleMarket market = IPendleMarket(markets[i]);

            // Once the market has entered frozen period, the weights suffer from more mathematical precision errors,
            // hence the Pendle market will stop doing weight shifting & stop trading
            if (block.timestamp >= market.lockStartTime()) continue;

            (, uint256 xytWeight, , uint256 tokenWeight, ) = market.getReserves();

            if (xytWeight + tokenWeight != RONE || xytWeight > tokenWeight) return false;
        }
        return true;
    }
}
