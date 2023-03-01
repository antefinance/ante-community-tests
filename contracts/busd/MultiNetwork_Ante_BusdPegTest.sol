// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

// Ante Test to check BUSD remains +- 5% of USD
contract MultiNetworkAnteBusdPegTest is AnteTest("BUSD is pegged to +- 5% of USD") {

    address public BUSD;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _busd, address _priceFeed) {
        protocolName = "BUSD";
        BUSD = _busd;
        testedContracts = [_busd];
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
