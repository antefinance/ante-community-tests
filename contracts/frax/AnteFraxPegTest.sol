// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import { AnteTest } from "../AnteTest.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Checks if FRAX stablecoin remains pegged to 1 USD
/// @author 0x11d1f1945414B60c4aC9e850dfD7bEB6B153d128
/// @notice Ante Test to check FRAX remains +- 5% of USD
contract AnteFraxPegTest is AnteTest("FRAX is pegged to +- 5% of USD") {
    // https://etherscan.io/token/0x853d955aCEf822Db058eb8505911ED77F175b99e
    address public constant fraxAddr = 0x853d955aCEf822Db058eb8505911ED77F175b99e;

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: BUSD/USD
     * Address: 0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD
     */
    constructor() {
        protocolName = "Frax Finance";
        testedContracts = [fraxAddr];
        priceFeed = AggregatorV3Interface(0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD);
    }

    /// @notice Use Chainlink Aggregator to check the FRAX price
    /// @return true if FRAX remains withint +- 5% of USD
    function checkTestPasses() public view override returns (bool) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (95000000 < price && price < 105000000);
    }
}
