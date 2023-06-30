// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


/// @title Checks that Aethernity Owner doesn't rug all Aether NFT
/// @author 0xa0e7Fb16cdE37Ebf2ceD6C89fbAe8780B8497e12
contract AnteAethernityOwnerTest is AnteTest("Aethernity Owner doesn't rug all Aether NFT") {
    // https://optimistic.etherscan.io/address/0xa49cee842116a89299a721d831bcf0511e8f6a15
    address public constant HOLDER_ADDRESS = 0xA49CEE842116A89299A721D831BCf0511E8F6A15;

    // https://optimistic.etherscan.io/address/0xf61ec3b18fe70711a2e8dc52916998eebb851517
    IERC721 public constant NFT = IERC721(0xF61Ec3b18fe70711a2e8dc52916998eEBB851517);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        thresholdBalance = 1;

        protocolName = "Aethernity";

        testedContracts = [address(NFT), HOLDER_ADDRESS];
    }

    /// @notice test to check if Aethernity Owner holds at least 1 Aether NFT
    /// @return true if Aether balance of Aethernity owner is >= 1
    function checkTestPasses() public view override returns (bool) {
        return (NFT.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
