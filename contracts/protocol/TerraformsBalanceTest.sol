// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// ==  Running an Ante Test using an NFT Balance token Terraforms
// ==  Test name - Fingerprints DAO holds >=5 Terraforms NFTs

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[Target][NFT]BalanceAbove[Threshold]Test
// TODO 2. Update target protocol, holder address, token, and balance threshold (marked with TODO)
// TODO 3. Replace instances of [TOKEN], [HOLDER], and [THRESHOLD] as needed

/// @title Checks that [HOLDER] holds at least [THRESHOLD] [NFT]s
/// @author Put your ETH address here
/// @notice Ante Test to check
contract TerraformsBalanceTest is AnteTest("Fingerprints DAO holds >=5 Terraforms NFTs") {
    // TODO update holder address and block explorer link   
    // https://etherscan.io/address/0xDBfD76AF2157Dc15eE4e57F3f942bB45Ba84aF24
    address public constant HOLDER_ADDRESS = 0xbC49de68bCBD164574847A7ced47e7475179C76B;

    // TODO update token address and block explorer link
    // https://etherscan.io/address/0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D
    IERC721 public constant NFT = IERC721(0x4E1f41613c9084FdB9E34E11fAE9412427480e56);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        // TODO replace 100 with desired threshold
        thresholdBalance = 5;

        // TODO replace "Project" with target NFT collection name
        protocolName = "Terraforms";

        testedContracts = [address(NFT), HOLDER_ADDRESS];
    }

    /// @notice test to check if [HOLDER] owns >= [THRESHOLD] [NFT]s
    /// @return true if [NFT] balance of [HOLDER] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        return (NFT.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
