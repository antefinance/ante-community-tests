// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";
import "hardhat/console.sol";

interface ICurveFiSwap {
    function get_best_rate(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (address, uint256);
}

// Ante Test to check USDT remains > 0.90
contract AnteUSDTCurvePegTest is AnteTest("USDT vs USDC is above 90 cents on the dollar") {
    // https://etherscan.io/token/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address public constant TetherAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant CurveFiRegistry = 0x2393c368C70B42f055a4932a3fbeC2AC9C548011;

    constructor() {
        protocolName = "USDT";
        testedContracts = [TetherAddr];
    }

    /**
     * Uses Curve Registry to get best rate for 100K USDC to USDT swap
     * USDC Contract: https://etherscan.io/token/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
     */
    function checkTestPasses() public view override returns (bool) {
        (, uint256 price) = ICurveFiSwap(CurveFiRegistry).get_best_rate(
            TetherAddr,
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            100000000000
        );
        console.log("Will receive %s tokens", price);
        return (90000000000 < price);
    }
}
