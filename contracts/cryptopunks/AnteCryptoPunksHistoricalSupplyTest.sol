// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";

interface IAxiomV0StoragePf {
    function isSlotAttestationValid(uint32, address, uint256, uint256) external view returns (bool);
}

/// @title Checks that the total supply of CryptoPunks never exceeded 10,000
/// @author 0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4 (abitwhaleish.eth)
/// @notice Ante Test to check the the total supply of CryptoPunks has never
///         exceeded 10,000
contract AnteCryptoPunksHistoricalSupplyTest is
    AnteTest("CryptoPunks total supply has never exceeded 10k")
{
    // https://etherscan.io/address/0xBFB98E8229a196EF6a13b04b121d310AFEC43574
    address public constant AXIOM_V0_STORAGE_PF = 0xBFB98E8229a196EF6a13b04b121d310AFEC43574;

    // https://etherscan.io/address/0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB
    address public constant CRYPTOPUNKS = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    uint256 public constant MAX_SUPPLY = 10_000;

    // claim storage variables
    uint32 public claimBlockNumber;
    uint256 public constant CLAIM_SLOT_NUMBER = 6; // totalSupply storage slot
    uint256 public claimTotalSupply;

    constructor() {
        protocolName = "CryptoPunks";
        testedContracts = [CRYPTOPUNKS];
    }

    function getStateTypes() external pure override returns (string memory) {
        return "uint32,uint256";
    }

    function getStateNames() external pure override returns (string memory) {
        return "blockNumber,totalSupply";
    }

    /// @notice Checks if a valid storage proof exists on Axiom that the total
    ///         supply of CryptoPunks exceeded 10,000 at some point. To check:
    ///         1. Generate a proof at https://demo.axiom.xyz/custom for
    ///            Block number: The historic block number to check
    ///            Address:      0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB
    ///            Storage slot: 6
    ///            and "Submit Attestation" on-chain
    ///         2. Call setStateAndCheckTestPasses with the block number and
    ///            slot value
    /// @return true if there exists a storage proof such that totalSupply
    ///         in the CryptoPunks contract was greater than 10000 at some
    ///         block in the past.
    function checkTestPasses() public view override returns (bool) {
        if (claimTotalSupply <= MAX_SUPPLY) {
            return true;
        }

        return !IAxiomV0StoragePf(AXIOM_V0_STORAGE_PF).isSlotAttestationValid(
            claimBlockNumber, 
            CRYPTOPUNKS, 
            CLAIM_SLOT_NUMBER, 
            claimTotalSupply
        );
    }

    function _setState(bytes memory _state) internal override {
        /// @notice sets the claim parameters to check Axiom for
        /// claimBlockNumber - block number the claim is made for
        /// claimTotalSupply - totalSupply of CryptoPunks at that block number
        (
            uint32 claimBlockNumber, 
            uint256 claimTotalSupply
        ) = abi.decode(
            _state,
            (uint32, uint256)
        );
    }
}
