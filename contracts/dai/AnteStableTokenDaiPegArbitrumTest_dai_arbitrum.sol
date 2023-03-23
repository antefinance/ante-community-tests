// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenDaiPegArbitrumTest DAI Arbitrum
/// @notice Ante Test to check if DAI Arbitrum pegs between +- 5% of USD
contract AnteStableTokenDaiPegArbitrumTest is AnteTest("DAI on Arbitrum is pegged to +- 5% of USD") {

    address public constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0xc5C8E77B397E531B8EC06BFb0048328B30E9eCfB);
    
    constructor() {
        protocolName = "DAI";
        testedContracts = [0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
