// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenUsdcOptimismPegTest USDC Optimism
/// @notice Ante Test to check if USDC Optimism pegs between +- 5% of USD
contract AnteStableTokenUsdcOptimismPegTest is AnteTest("USDC on Optimism is pegged to +- 5% of USD") {

    address public constant USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x16a9FA2FDa030272Ce99B29CF780dFA30361E0f3);
    
    constructor() {
        protocolName = "USDC";
        testedContracts = [0x7F5c764cBc14f9669B88837ca1490cCa17c31607];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
