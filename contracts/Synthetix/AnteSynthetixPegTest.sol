// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface IAggregatorInterface {
    function getRate(address srcToken, address dstToken, bool wrapper) external view returns (uint256);
}

/// @title AnteSynthetixPegTest
/// @notice Uses Synthetix' most common synths (sUSDC, sETH) and ensure that they are pegged to
/// the reserve currencies (USDC, ETH) within 3%
contract AnteSynthetixPegTest is AnteTest("Synthetix Tokens Stay Pegged Within 3%") {

    // https://docs.synthetix.io/addresses/
    address private constant ADDRESS_SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address private constant ADDRESS_SETH = 0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb;
    address private constant ADDRESS_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant ADDRESS_WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    // https://docs.1inch.io/docs/spot-price-aggregator/introduction/#
    IAggregatorInterface oneInch = IAggregatorInterface(0x07D91f5fb9Bf7798734C3f606dB065549F6893bb);
    
    constructor() {
        protocolName = "Synthetix";
        testedContracts = [ADDRESS_SUSD, ADDRESS_SETH];
    }

    /// @return true if the peg is within 3%
    function checkTestPasses() public view override returns (bool) {
        // Last two zeroes.
        uint256 susd = oneInch.getRate(ADDRESS_SUSD, ADDRESS_USDC, false) / 1e4;
        uint256 seth = oneInch.getRate(ADDRESS_SETH, ADDRESS_WETH, false) / 1e16;

        return (susd < 103 && susd > 97) && (seth < 103 && seth > 97);
    }
}
