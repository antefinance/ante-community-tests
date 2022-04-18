// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

interface LongShortPair {
    function longToken() external view returns (address);
    function shortToken() external view returns (address);
}

/// @notice Ensure that issued tokens are less than or equal to LSP collateral * collateral per pair
contract AnteLSPCollateralTest is AnteTest("Ensure that collateral x CPP is correct") {

    // To verify this LSP, go to https://etherscan.io/address/0x439a990f83250FE2E5E6b8059F540af1dA1Ba04D#events
    // Under events tab, you will see several LSPs have been created
    // Select the TX hash starting with 0x141f. You will see the LSP address

    LongShortPair private immutable contractLSP;
    address private immutable addressLSP;
    address private immutable addressToken;

    address private immutable addressLong;
    address private immutable addressShort;

    IERC20 private immutable contractToken;
    IERC20 private immutable contractLong;
    IERC20 private immutable contractShort;

    /// @param _addressLSP The address of the Long Short Pair
    /// @param _addressToken The address of the token that is being bet on
    constructor (address _addressLSP, address _addressToken) {
        protocolName = "UMA";
        testedContracts = [_addressLSP];

        addressLSP = _addressLSP;
        addressToken = _addressToken;

        contractLSP = LongShortPair(addressLSP);
        addressLong = contractLSP.longToken();
        addressShort = contractLSP.shortToken();

        contractToken = IERC20(addressToken);
        contractLong = IERC20(addressLong);
        contractShort = IERC20(addressShort);
    }
    
    /// @return if the LSP collateral >= issued tokens
    function checkTestPasses() public view override returns (bool) {
        // insert logic here to check the My Protocol invariant
        uint256 collateral = contractToken.balanceOf(addressLSP);
        uint256 supply = contractLong.totalSupply() + contractShort.totalSupply();

        return collateral >= supply;
    }
}
