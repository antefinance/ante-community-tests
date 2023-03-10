// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenFraxOptimismPegTest frax Optimism
/// @notice Ante Test to check if frax Optimism pegs between +- 5% of USD
contract AnteStableTokenFraxOptimismPegTest is AnteTest("FRAX on Optimism is pegged to +- 5% of USD") {

    address public constant FRAX = 0x2E3D870790dC77A83DD1d18184Acc7439A53f475;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0xc7D132BeCAbE7Dcc4204841F33bae45841e41D9C);
    
    constructor() {
        protocolName = "frax";
        testedContracts = [0x2E3D870790dC77A83DD1d18184Acc7439A53f475];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
