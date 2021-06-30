// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "./interfaces/AnteTest.sol";

interface IVault {
    function getPricePerFullShare() external view returns (uint);
}

// Ante Test to check yYFI stakeholders can withdraw their full deposit
contract Ante_yYFI_PricePerShareTest is AnteTest("yYFI vault is in profit") {
    // https://etherscan.io/address/0xBA2E7Fed597fd0E3e70f5130BcDbbFE06bB94fe1
    address public constant yYFIAddr = 0xBA2E7Fed597fd0E3e70f5130BcDbbFE06bB94fe1;

    IVault public yYFIVault = IVault(yYFIAddr);

    constructor () {
        protocolName = "YFI";
        testedContracts = [yYFIAddr];
    }
    
    function checkTestPasses() public view override returns (bool) {
        return (uint(yYFIVault.getPricePerFullShare()) >= 1e18);
    }
}
