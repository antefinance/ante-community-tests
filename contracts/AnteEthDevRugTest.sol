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

import "./interfaces/AnteTest.sol";

// Ante Test to check if EthDev multisig "rugs" 99% of its ETH
// NOTE: this is JUST ILLUSTRATIVE; the multisig CAN MOVE FUNDS FOR ANY REASON
contract AnteEthDevRugTest is AnteTest("EthDev MultiSig Doesnt Rug 99% of its ETH Test") { 
    // https://etherscan.io/address/0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
    address public constant ethDevAddr = 0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe;

    // 2021-05-24: EthDev has 394k ETH, so -99% is ~4k ETH
    uint256 public constant RUG_THRESHOLD = 4 * 1000 * 1e18; 

    constructor () {
        testedContracts = [ethDevAddr];
    }
    
    function checkTestPasses() public view override returns (bool) {
        return ethDevAddr.balance >= RUG_THRESHOLD;
    }
}
