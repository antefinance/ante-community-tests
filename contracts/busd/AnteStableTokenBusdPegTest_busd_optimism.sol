// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenBusdPegTest BUSD Optimism
/// @notice Ante Test to check if BUSD Optimism pegs between +- 5% of USD
contract AnteStableTokenBusdPegTest is AnteTest("BUSD on Optimism is pegged to +- 5% of USD") {

    address public constant BUSD = 0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0xC1cB3b7cbB3e786aB85ea28489f332f4FAEd5Bc4);
    
    constructor() {
        protocolName = "BUSD";
        testedContracts = [0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
