// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// @title  Stargate TVL Plunge Test (Arbitrum)
// @notice Ante Test to check that assets in Stargate pools on Arbitrum
//         (currently USDT, USDC, ETH) do not plunge by 90% from the time of
//         test deploy
contract AnteStargateArbitrumTotalTVLPlungeTest is AnteTest("Stargate TVL on Arbitrum does not plunge by 90%") {
    address constant STARGATE_USDT_POOL = 0xB6CfcF89a7B22988bfC96632aC2A9D6daB60d641;
    address constant STARGATE_USDC_POOL = 0x892785f33CdeE22A30AEF750F285E18c18040c3e;
    address constant STARGATE_SGETH_POOL = 0x915A55e36A01285A14f05dE6e81ED9cE89772f8e;

    IERC20 constant USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 constant USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 constant SGETH = IERC20(0x82CbeCF39bEe528B5476FE6d1550af59a9dB6Fc0);

    AggregatorV3Interface internal priceFeed;

    uint256 public immutable tvlThreshold;

    constructor() {
        protocolName = "Stargate";
        testedContracts = [STARGATE_USDT_POOL, STARGATE_USDC_POOL, STARGATE_SGETH_POOL];

        // Chainlink ETH/USD price feed on Arbitrum Mainnet
        // https://arbiscan.io/address/0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        priceFeed = AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612);

        tvlThreshold = getCurrentBalances() / 10;
    }

    // @notice Get current pool balances
    // @return the sum of tested pool balances (USDT, USDC, ETH)
    function getCurrentBalances() public view returns (uint256) {
        // Grab latest price from Chainlink feed
        (, int256 ethUsdPrice, , , ) = priceFeed.latestRoundData();

        // Exclude negative prices so we can safely cast to uint
        if (ethUsdPrice < 0) {
            ethUsdPrice = 0;
        }

        return (USDT.balanceOf(STARGATE_USDT_POOL) + // 6 decimals
            USDC.balanceOf(STARGATE_USDC_POOL) + // 6 decimals
            (SGETH.balanceOf(STARGATE_SGETH_POOL) * uint256(ethUsdPrice)) /
            10**20);
        // 18 decimals + 8 decimal price
    }

    // @notice Check if current pool balances are greater than TVL threshold
    // @return true if current TVL > 10% of TVL at time of test deploy
    function checkTestPasses() public view override returns (bool) {
        return (getCurrentBalances() > tvlThreshold);
    }
}
