// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./libraries/MathLib.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

/// @notice Ante Test to check that the total OT divided by the exchange rate never exceed the amount of sushi lp tokens deposited
/// into Pendle
contract AntePendleSushiPEPForgeTest is AnteTest("Pendle Sushi PEP Forge Test") {
    using SafeMath for uint256;
    using Math for uint256;
    // ownership tokens - sushi_OT_PE/P_Dec_29_2022
    address public ot = 0xbF682bd31a615123D28d611b38b0aE3d2b675C2C;

    // lp token holders after users have deposit their tokens into Pendle
    // sushi_PE/P_Dec_29_2022
    address public yieldTokenHolder = 0xbFD6b497dCa3e5D1fA4BbD52996d400980C29Eb7;

    // sushi lp token - sushi_LP_PE/P_Dec_29_2022
    address public yieldToken = 0x37922C69b08BABcCEaE735A31235c81f1d1e8E43;

    // all interactions between users and Pendle are through the router
    address public router = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;
    // pendle forge for sushi yield-bearing token
    address public forge = 0x6B0e6B4C0ee4b6460E5CD35A3625a172FE9d3930;

    constructor() {
        protocolName = "Pendle";

        testedContracts.push(ot);
        testedContracts.push(yieldTokenHolder);
        testedContracts.push(yieldToken);
        testedContracts.push(router);
        testedContracts.push(forge);
    }

    /// @notice checks total supply of OT divided by the exhchangeRate vs number of lp tokens deposited for each supported asset
    /// @return true if total supply of OT divided by exchangeRate of OT and LP
    /// is smaller or equal to the number of lp tokens deposited
    function checkTestPasses() public view override returns (bool) {
        uint256 lpBal = IERC20(yieldToken).balanceOf(yieldTokenHolder);

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(yieldToken).getReserves();
        uint256 currentK = Math.sqrt(reserve0.mul(reserve1));
        uint256 totalSupply = IUniswapV2Pair(yieldToken).totalSupply();
        uint256 rate = currentK.rdiv(totalSupply);

        // <= lpBal * 101% to account for precision issues
        return IERC20(ot).totalSupply().rdiv(rate) <= lpBal.mul(101).div(100);
    }
}
