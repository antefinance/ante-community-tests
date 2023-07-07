// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

/// @title AnteStableTokenFraxPegArbitrumTest frax Arbitrum
/// @notice Ante Test to check if frax Arbitrum pegs between +- 5% of USD
contract AnteStableTokenFraxPegArbitrumTest is AnteTest("FRAX on Arbitrum is pegged to +- 5% of USD") {

    address public constant FRAX = 0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F;

    AggregatorV3Interface public constant priceFeed = AggregatorV3Interface(0x0809E3d38d1B4214958faf06D8b1B1a2b73f2ab8);
    
    constructor() {
        protocolName = "frax";
        testedContracts = [0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F];
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
