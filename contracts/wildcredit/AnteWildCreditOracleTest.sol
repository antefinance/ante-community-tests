// SPDX-License-Identifier: MIT

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.8.0;

import "../AnteTest.sol";

interface IPriceOracle {
    function tokenPrice(address _token) external view returns (uint256);
}

// Ante Test to check if the Wild Credit $WILD token price is always within 1% of the UniswapV3Price oracle
// This will be useful in the event Wild Credit ever changes the price oracle and there would be discrepancies
contract AnteWildCreditOracleTest is
    AnteTest("Wild.Credit Controller price oracle is always the within 1% of Wild.Credit UniswapV3Oracle")
{
    address public constant wildCreditTokenAddr = 0x08A75dbC7167714CeaC1a8e43a8d643A4EDd625a;
    IPriceOracle public constant uniswapV3Oracle = IPriceOracle(0x3D619bc03014917d3B27B3B86452346af36e58de);
    IPriceOracle public constant controllerPriceOracle = IPriceOracle(0x45ee906E9CFAE0aabDB194D6180A3A119D4376C4);
    uint256 accuracy = 10e12;

    constructor() {
        protocolName = "Wild Credit";
        testedContracts = [address(controllerPriceOracle)];
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 price1 = uniswapV3Oracle.tokenPrice(wildCreditTokenAddr);
        uint256 price2 = controllerPriceOracle.tokenPrice(wildCreditTokenAddr);
        return ((price1 * accuracy) / (price2)) > 99e11 || ((price2 * accuracy) / (price1)) > 99e11;
    }
}
