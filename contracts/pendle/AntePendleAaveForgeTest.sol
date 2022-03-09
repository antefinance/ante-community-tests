// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./libraries/MathLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Ante Test to check that the total OT never exceed the amount of aave yield-bearing tokens deposited
/// into Pendle, hence 1 OT can always redeem back 1 aave yield-bearing token
contract AntePendleAaveForgeTest is AnteTest("Pendle Aave Forge Test") {
    using SafeMath for uint256;
    // ownership tokens
    address public ot = 0x8fcb1783bF4b71A51F702aF0c266729C4592204a; // aUSDC_OT_Dec_29_2022

    // yield-bearing token holders after users have deposit their tokens into Pendle
    address public yieldTokenHolder = 0x33d3071cfa7404a406edB5826A11620282021745; // aUSDC_Dec_29_2022

    // aave yield-bearing token
    address public yieldToken = 0xBcca60bB61934080951369a648Fb03DF4F96263C; // aUSDC

    // all interactions between users and Pendle are through the router
    address public router = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;
    // pendle forge for aave yield-bearing token
    address public forge = 0x9902475a6Ffc0377b034Bf469EE0879f3Bd273FB;

    constructor() {
        protocolName = "Pendle";

        testedContracts.push(ot);
        testedContracts.push(yieldTokenHolder);
        testedContracts.push(yieldToken);
        testedContracts.push(router);
        testedContracts.push(forge);
    }

    /// @notice checks total supply of OT vs number of yield tokens deposited for each supported asset
    /// @return true if total supply of OT is smaller or equal to the number of yield-bearing tokens deposited
    function checkTestPasses() public view override returns (bool) {
        return IERC20(ot).totalSupply() <= IERC20(yieldToken).balanceOf(yieldTokenHolder).mul(101).div(100);
    }
}
