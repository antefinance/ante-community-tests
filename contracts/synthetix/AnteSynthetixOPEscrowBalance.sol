// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../AnteTest.sol";

/// @title AnteSynthetixOPEscrowBalanceTest
contract AnteSynthetixOPEscrowBalance is AnteTest("Synthetix Reward Escrow on OP holds >350K $SNX") {
    // https://docs.synthetix.io/addresses/
    address private constant ADDRESS_SNX = 0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4;
    address private constant ADDRESS_OP_ESCROW = 0x6330D5F08f51057F36F46d6751eCDc0c65Ef7E9e;

    constructor() {
        protocolName = "Synthetix";
        testedContracts = [ADDRESS_SNX, ADDRESS_OP_ESCROW];
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 balance = IERC20(ADDRESS_SNX).balanceOf(ADDRESS_OP_ESCROW);

        return balance > 350000 * 10**18;
    }
}
