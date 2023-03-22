// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenTetherPegArbitrumTest tether Arbitrum
/// @notice Ante Test to check if tether Arbitrum pegs between +- 5% of USD
contract AnteStableTokenTetherPegArbitrumTest is AnteTest("USDT on Arbitrum is pegged to +- 5% of USD") {

    address public constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7);
    
    constructor() {
        protocolName = "tether";
        testedContracts = [0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
