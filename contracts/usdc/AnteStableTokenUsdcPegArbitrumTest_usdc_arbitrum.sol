// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenUsdcPegArbitrumTest USDC Arbitrum
/// @notice Ante Test to check if USDC Arbitrum pegs between +- 5% of USD
contract AnteStableTokenUsdcPegArbitrumTest is AnteTest("USDC on Arbitrum is pegged to +- 5% of USD") {

    address public constant USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3);
    
    constructor() {
        protocolName = "USDC";
        testedContracts = [0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
