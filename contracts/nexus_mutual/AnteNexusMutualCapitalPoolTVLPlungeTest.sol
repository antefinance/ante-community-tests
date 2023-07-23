// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// @title  Nexus Mutual Capital Pool TVL Plunge Test
// @notice Ante Test to check that assets in the Nexus Mutual capital pool
//         (currently ETH, stETH, and DAI) does not plunge by 90% from the time of
//         test deploy
contract AnteNexusMutualCapitalPoolTVLPlungeTest is AnteTest("Nexus Mutual Capital Pool TVL does not plunge by 90%") {
    address constant NEXUS_MUTUAL_POOL = 0xcafea112Db32436c2390F5EC988f3aDB96870627;

    IERC20 constant STETH = IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    AggregatorV3Interface internal ETHPriceFeed;
    AggregatorV3Interface internal stETHPriceFeed;
    AggregatorV3Interface internal DAIPriceFeed;

    uint256 immutable tvlThreshold;

    constructor() {
        protocolName = "Nexus Mutual";
        testedContracts = [NEXUS_MUTUAL_POOL];

        // Chainlink ETH/USD price feeds
        ETHPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        stETHPriceFeed = AggregatorV3Interface(0xCfE54B5cD566aB89272946F602D76Ea879CAb4a8);
        DAIPriceFeed = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);


        tvlThreshold = getCurrentTVL() / 10;
    }

    // @return current pool ETH balance (18 decimals)
    function getETHBalance() public view returns (uint256) {
        return NEXUS_MUTUAL_POOL.balance;
    }
    
    // @return current pool stETH balance (18 decimals)
    function getSTETHBalance() public view returns (uint256) {
        return STETH.balanceOf(NEXUS_MUTUAL_POOL);
    }
    
    // @return current pool DAI balance (18 decimals)
    function getDAIBalance() public view returns (uint256) {
        return DAI.balanceOf(NEXUS_MUTUAL_POOL);
    }

    // @return 0 if price is negative, or price
    function excludeNegative(int256 price) private pure returns (int256) {
        if (price < 0) {
            return 0;
        }
        else return price;
    }

    // @notice Get current pool balances
    // @return the sum of tested pool balances (ETH, stETH, DAI) with 6 decimals
    function getCurrentTVL() public view returns (uint256) {
        // Grab latest price from Chainlink feed
        (, int256 ethUsdPrice, , , ) = ETHPriceFeed.latestRoundData();
        (, int256 stethUsdPrice, , , ) = stETHPriceFeed.latestRoundData();
        (, int256 daiUsdPrice, , , ) = DAIPriceFeed.latestRoundData();

        // Exclude negative prices so we can safely cast to uint
        ethUsdPrice = excludeNegative(ethUsdPrice);
        stethUsdPrice = excludeNegative(stethUsdPrice);
        daiUsdPrice = excludeNegative(daiUsdPrice);

        return (
            getETHBalance() / 10**15 * uint256(ethUsdPrice) / 10**5 + 
            getSTETHBalance() / 10**15 * uint256(stethUsdPrice) / 10**5 + 
            getDAIBalance() / 10**15 * uint256(daiUsdPrice) / 10**5
        );
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (getCurrentTVL() > tvlThreshold);
    }
}
