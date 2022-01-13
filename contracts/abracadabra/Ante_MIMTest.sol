// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../AnteTest.sol";

// Ante Test to check MIM remains +- 5% of USD
contract AnteMIMPegTest is AnteTest("MIM is pegged to USD") {
    // https://etherscan.io/token/0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3
    address public constant MIMAddr = 0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3;

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: MIM/USD
     * Address: 0x7A364e8770418566e3eb2001A96116E6138Eb32F
     */
    constructor() {
        protocolName = "Abracadabra.money: MIM Token";
        testedContracts = [MIMAddr];
        priceFeed = AggregatorV3Interface(0x7A364e8770418566e3eb2001A96116E6138Eb32F);
    }

    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
