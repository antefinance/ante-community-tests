// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./interfaces/IPendleMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Ante Test to check the reserve data balance is backed by the actual balance of the market
contract AntePendleMarketBalanceTest is AnteTest("Pendle Market Balance Test") {
    address[4] public markets = [
        0x8315BcBC2c5C1Ef09B71731ab3827b0808A2D6bD, // YT-aUSDC/USDC_Dec_29_2022
        0xB26C86330FC7F97533051F2F8cD0a90C2E82b5EE, // YT-cDai/USDC_Dec_29_2022
        0x79c05Da47dC20ff9376B2f7DbF8ae0c994C3A0D0, // YT-ETHUSDC/USDC_Dec_29_2022
        0x685d32f394a5F03e78a1A0F6A91B4E2bf6F52cfE // YT-PENDLEETH/PENDLE_Dec_29_2022
    ];

    constructor() {
        protocolName = "Pendle";

        for (uint256 i = 0; i < markets.length; ++i) {
            testedContracts.push(markets[i]);
        }
    }

    /// @notice check reserve data is backed by the actual balance of each market
    /// @return true if xytBalance and tokenBalance never exceed the actual balances of each market
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < markets.length; ++i) {
            IPendleMarket market = IPendleMarket(markets[i]);

            // Once the market has entered frozen period, the getReserves function is not reliable due to the fact that
            // the _updateWeightDry may revert. It's a known issue that doesn't affect the contract at all (since this
            // function is only used for informational purposes).
            if (block.timestamp >= market.lockStartTime()) continue;

            IERC20 xyt = IERC20(market.xyt());
            IERC20 token = IERC20(market.token());

            (uint256 xytBalance, , uint256 tokenBalance, , ) = market.getReserves();

            if (xytBalance > xyt.balanceOf(address(market))) return false;
            if (tokenBalance > token.balanceOf(address(market))) return false;
        }
        return true;
    }
}
