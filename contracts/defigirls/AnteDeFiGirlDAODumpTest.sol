// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title Checks that defigirldao.eth doesn't sell any DeFi Girls before 2023-09-01
/// @author 0xTestooor
/// @notice Ante Test to check that the total number of DeFi Girls held by
/// defigirldao.eth doesn't decrease before 2023-09-01 (commitment made via
/// https://discord.com/channels/1016881386151481414/1016905168513663066/1023494063300825108:
/// "Our DAO Wallet has now been established, at DeFiGirlsDAO.eth. Our DAO's
/// current objective is in accumulating a collection of DeFi Girls NFTs from
/// the open market; note that no NFT may be sold from this wallet until
/// September 2023 at the earliest, at a max rate of 2 NFTs/Day, and with the
/// majority consensus of all holders."
contract AnteDeFiGirlDAODumpTest is AnteTest("DeFiGirlDAO.eth doesn't dump before Sept 2023") {
    // https://etherscan.io/address/0x754bbb703EEada12A6988c0e548306299A263a08
    address public constant DEFIGIRLDAO = 0x754bbb703EEada12A6988c0e548306299A263a08;
    // https://etherscan.io/address/0x3B14d194c8CF46402beB9820dc218A15e7B0A38f
    IERC721 public constant DFGIRL = IERC721(0x3B14d194c8CF46402beB9820dc218A15e7B0A38f);

    uint256 public constant COMMITMENT_END = 1693526399; // 2023-08-31 23:59:59 UTC

    // Will be set to desired NFT balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        protocolName = "DeFi Girls";
        testedContracts = [address(DFGIRL), DEFIGIRLDAO];

        thresholdBalance = DFGIRL.balanceOf(DEFIGIRLDAO); // should be 780
    }

    /// @notice test to check if defigirldao.eth owns >= 780 DeFi Girls until 2023-09-01
    /// @return true if DeFi Girl balance of defigirldao.eth is >= 780 or it is 2023-09-01 or later
    function checkTestPasses() public view override returns (bool) {
        if (block.timestamp > COMMITMENT_END) {
            // if 2023-09-01 or later, always returns true
            return true;
        } else {
            // otherwise, return true if balance > threshold
            return (DFGIRL.balanceOf(DEFIGIRLDAO) >= thresholdBalance);
        }
        // technically this means defigirldao.eth could buy/sell DeFi Girls as
        // long as the total number owned remains at or above 780, but this is
        // probably a reasonable approximation
    }
}
