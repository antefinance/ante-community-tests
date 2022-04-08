// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

// @title Stargate TVL Plunge Test
// @notice Ensure that Stargate keeps a TVL of > 10%"
contract StargateTVLTest is AnteTest("Ensure that stargate keeps a TVL of > 10%") {

    address constant USDT_STARGATE = 0x38EA452219524Bb87e18dE1C24D3bB59510BD783;
    address constant USDC_STARGATE = 0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56;

    IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 immutable oldTVL;

    constructor() {
        testedContracts = [USDT_STARGATE, USDC_STARGATE];
        protocolName = "Stargate";

        oldTVL = USDT.balanceOf(USDT_STARGATE) + USDC.balanceOf(USDC_STARGATE);
    }

    // @return the current tvl
    function getBalances() public view returns(uint256){
        return USDT.balanceOf(USDT_STARGATE) + USDC.balanceOf(USDC_STARGATE);
    }

    // @return if the current tvl is above 10% of the original TVL
    function checkTestPasses() public view override returns (bool) {
        return (100 * getBalances() / oldTVL > 10);
    }
}
