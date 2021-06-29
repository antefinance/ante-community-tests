// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/AnteTest.sol";

// Ante Test to check WBTC supply never exceeds 21 million
contract AnteWBTCSupplyTest is AnteTest("Wrapped BTC (WBTC) supply doesn't exceed 21m") {
    // https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599#code
    address public constant wBTCAddr = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; 

    //21 million * 1e8 (for decimals), maximum total Bitcoin supply
    uint256 constant THRESHOLD_SUPPLY = 21 * 1000 * 1000 * 1e8; 

    IERC20 public wBTCToken = IERC20(wBTCAddr);

    constructor () {
        protocolName = "WBTC";
        testedContracts = [wBTCAddr];
    }
    
    function checkTestPasses() public view override returns (bool) {
        return (wBTCToken.totalSupply() <= THRESHOLD_SUPPLY);
    }
}
