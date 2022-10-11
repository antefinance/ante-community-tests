// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// ==INSTRUCTIONS==
// TODO 1. Rename the contract and file in the form Ante[Target][NFT]BalanceAbove[Threshold]Test
// TODO 2. Update target protocol, holder address, token, and balance threshold (marked with TODO)
// TODO 3. Replace instances of [TOKEN], [HOLDER], and [THRESHOLD] as needed

/// @title Checks that [HOLDER] holds at least [THRESHOLD] [NFT]s
/// @notice Ante Test to check
contract AnteNFTBalanceTestTemplate is AnteTest("[TARGET] [TOKEN] balance remains >= [THRESHOLD]") {
    // TODO update holder address and block explorer link
    // https://etherscan.io/address/0xDBfD76AF2157Dc15eE4e57F3f942bB45Ba84aF24
    address public constant HOLDER_ADDRESS = 0xDBfD76AF2157Dc15eE4e57F3f942bB45Ba84aF24;

    // TODO update token address and block explorer link
    // https://etherscan.io/address/0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D
    IERC721 public constant NFT = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        // TODO replace 100 with desired threshold
        thresholdBalance = 100;

        // TODO replace "Project" with target NFT collection name
        protocolName = "Project";

        testedContracts = [address(NFT), HOLDER_ADDRESS];
    }

    /// @notice test to check if [HOLDER] owns >= [THRESHOLD] [NFT]s
    /// @return true if [NFT] balance of [HOLDER] is >= [THRESHOLD]
    function checkTestPasses() public view override returns (bool) {
        return (NFT.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
