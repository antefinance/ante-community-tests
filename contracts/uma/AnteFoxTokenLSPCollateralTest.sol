// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

interface LongShortPair {
    function longToken() external view returns (address);
    function shortToken() external view returns (address);
}

/// @notice Ensure that issued tokens are less than or equal to LSP collateral * collateral per pair
contract AnteFoxTokenLSPCollateralTest is AnteTest("Ensure that collateral x CPP is correct") {

    // To verify this LSP, go to https://etherscan.io/address/0x439a990f83250FE2E5E6b8059F540af1dA1Ba04D#events
    // Under events tab, you will see several LSPs have been created
    // Select the TX hash starting with 0x141f. You will see the LSP address

    address private addressFoxLSP = 0xE38f290eAC1f83A960c461100b0c7a231B9Cae16;
    LongShortPair private contractFoxLSP = LongShortPair(0xE38f290eAC1f83A960c461100b0c7a231B9Cae16);

    address private addressFoxToken = 0xc770EEfAd204B5180dF6a14Ee197D99d808ee52d;
    address private addressFoxLong = contractFoxLSP.longToken();
    address private addressFoxShort = contractFoxLSP.shortToken();

    IERC20 private contractFoxToken = IERC20(addressFoxToken);
    IERC20 private contractFoxLong = IERC20(addressFoxLong);
    IERC20 private contractFoxShort = IERC20(addressFoxShort);

    constructor () {
        protocolName = "UMA";
        testedContracts = [addressFoxLSP];
    }
    
    function checkTestPasses() public view override returns (bool) {
        // insert logic here to check the My Protocol invariant
        uint256 collateral = contractFoxToken.balanceOf(addressFoxLSP);
        uint256 supply = contractFoxLong.totalSupply() + contractFoxShort.totalSupply();

        return collateral >= supply;
    }
}
