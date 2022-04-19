// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

interface LongShortPair {
    function longToken() external view returns (address);
    function shortToken() external view returns (address);
    function collateralToken() external view returns (address);
    function collateralPerPair() external view returns (uint256);
}

/// @title AnteLSPCollateralTest
/// @notice Ensure that issued tokens are less than or equal to LSP collateral * collateral per pair
contract AnteLSPCollateralTest is AnteTest("Ensure that collateral x CPP is correct") {

    LongShortPair private immutable contractLSP;
    address private immutable addressLSP;
    address private immutable addressToken;

    address private immutable addressLong;
    address private immutable addressShort;

    IERC20 private immutable contractToken;
    IERC20 private immutable contractLong;
    IERC20 private immutable contractShort;

    /// @param _addressLSP The address of the Long Short Pair
    constructor (address _addressLSP) {
        protocolName = "UMA";
        testedContracts = [_addressLSP];

        addressLSP = _addressLSP;

        contractLSP = LongShortPair(addressLSP);
        addressLong = contractLSP.longToken();
        addressShort = contractLSP.shortToken();

        contractLong = IERC20(addressLong);
        contractShort = IERC20(addressShort);

        addressToken = contractLSP.collateralToken();
        contractToken = IERC20(addressToken);
    }
    
    /// @return if the LSP collateral >= issued tokens
    function checkTestPasses() public view override returns (bool) {
        // insert logic here to check the My Protocol invariant
        uint256 collateral = contractToken.balanceOf(addressLSP);
        uint256 collateralPerPair = contractLSP.collateralPerPair();

        uint256 longSupply = contractLong.totalSupply();
        uint256 shortSupply = contractShort.totalSupply();
        uint256 decimals = 10 ** contractToken.decimals();

        // The reason one side is multiplied by 10e18 is because when multiplying by collateralPerPair
        // The side is increaased by the collateral (eg 1.5) times 10e18
        return (collateral * decimals >= longSupply * collateralPerPair) 
                && (collateral * decimals >= shortSupply * collateralPerPair);
    }
}
