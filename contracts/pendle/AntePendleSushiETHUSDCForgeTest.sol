// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import "../AnteTest.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IMasterChef.sol";
import "./libraries/MathLib.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

/// @notice Ante Test to check that the total OT divided by the exchange rate never exceed the amount of sushi lp tokens deposited
/// into Pendle
contract AntePendleSushiETHUSDCForgeTest is AnteTest("Pendle Sushi ETHUSDC Forge Test") {
    using SafeMath for uint256;
    using Math for uint256;
    // ownership tokens - sushi_OT_ETH/USDC_Dec_29_2022
    address public ot = 0x322D6c69048330247165231EB7848A5C80a48878;

    // lp token holders after users have deposit their tokens into Pendle
    // sushi_ETH/USDC_Dec_29_2022
    address public yieldTokenHolder = 0xa06634BE609153b77355BFD09F9d59345939C59b;

    // sushi lp token - sushi_LP_ETH/USDC_Dec_29_2022
    address public yieldToken = 0x397FF1542f962076d0BFE58eA045FfA2d347ACa0;

    // sushi_ETH/USDC pid
    uint256 public pid = 1;
    // sushi_masterchef
    address public masterChef = 0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd;

    // all interactions between users and Pendle are through the router
    address public router = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;
    // pendle forge for sushi yield-bearing token
    address public forge = 0xA71bdADD4AaBee6c5005aaAbAC0Ddd27a6657251;

    constructor() {
        protocolName = "Pendle";

        testedContracts.push(ot);
        testedContracts.push(yieldTokenHolder);
        testedContracts.push(yieldToken);
        testedContracts.push(masterChef);
        testedContracts.push(router);
        testedContracts.push(forge);
    }

    /// @notice checks total supply of OT divided by the exhchangeRate vs number of lp tokens deposited for each supported asset
    /// @return true if total supply of OT divided by exchangeRate of OT and LP
    /// is smaller or equal to the number of lp tokens deposited
    function checkTestPasses() public view override returns (bool) {
        uint256 lpBal = IMasterChef(masterChef).userInfo(pid, yieldTokenHolder).amount;

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(yieldToken).getReserves();
        uint256 currentK = Math.sqrt(reserve0.mul(reserve1));
        uint256 totalSupply = IUniswapV2Pair(yieldToken).totalSupply();
        uint256 rate = currentK.rdiv(totalSupply);

        // <= lpBal * 101% to account for precision issues
        return IERC20(ot).totalSupply().rdiv(rate) <= lpBal.mul(101).div(100);
    }
}
