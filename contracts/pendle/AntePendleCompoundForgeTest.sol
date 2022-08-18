// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./interfaces/ICToken.sol";
import "./interfaces/IPendleCompoundForge.sol";
import "./libraries/MathLib.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

/// @notice Ante Test to check that the total OT supply divided by the exchangeRate never exceed the amount of compound yield-bearing tokens deposited
/// into Pendle
contract AntePendleCompoundForgeTest is AnteTest("Pendle Compound Forge Test") {
    using SafeMath for uint256;
    using Math for uint256;
    // ownership tokens
    address public ot = 0x3D4e7F52efaFb9E0C70179B688FC3965a75BCfEa; // cDAI_OT_Dec_29_2022

    // yield-bearing token holders after users have deposit their tokens into Pendle
    address public yieldTokenHolder = 0xb0aa68d8A0D56ae7276AB9E0E017965a67320c60; // cDAI_Dec_29_2022

    // compound yield-bearing token
    address public yieldToken = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643; // cDAI
    address public underlyingAsset = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI

    // all interactions between users and Pendle are through the router
    address public router = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;
    // pendle forge for compound yield-bearing token
    address public forge = 0xc02aC197a4D32D93D473779Fbea2DCA1fb313eD5;

    // cDAI exchange rate when forge initiated
    uint256 public immutable initialRate;

    constructor() {
        protocolName = "Pendle";

        testedContracts.push(ot);
        testedContracts.push(yieldTokenHolder);
        testedContracts.push(yieldToken);
        testedContracts.push(underlyingAsset);
        testedContracts.push(router);
        testedContracts.push(forge);

        initialRate = IPendleCompoundForge(forge).initialRate(underlyingAsset);
    }

    /// @notice checks total supply of OT divided by the exchangeRate vs number of yield tokens deposited for each supported asset
    /// @return true if total supply of OT divided by the exchangeRate is smaller or equal to the number of yield-bearing tokens deposited
    function checkTestPasses() public override returns (bool) {
        uint256 currentRate = ICToken(yieldToken).exchangeRateCurrent();
        uint256 otToYieldToken = IERC20(ot).totalSupply().mul(initialRate).div(currentRate);
        return otToYieldToken <= IERC20(yieldToken).balanceOf(yieldTokenHolder).mul(101).div(100);
    }
}
