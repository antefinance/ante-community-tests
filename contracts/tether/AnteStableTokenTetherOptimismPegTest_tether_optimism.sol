// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenTetherOptimismPegTest tether Optimism
/// @notice Ante Test to check if tether Optimism pegs between +- 5% of USD
contract AnteStableTokenTetherOptimismPegTest is AnteTest("USDT on Optimism is pegged to +- 5% of USD") {

    address public constant USDT = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0xECef79E109e997bCA29c1c0897ec9d7b03647F5E);
    
    constructor() {
        protocolName = "tether";
        testedContracts = [0x94b008aA00579c1307B0EF2c499aD98a8ce58e58];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
