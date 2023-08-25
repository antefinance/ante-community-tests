// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface ILendingPool {
    function oracle() external view returns (address);
}

/// @title Checks that the LlamaLend oracle used by TubbyLoan never
///        returns a Tubby Cats floor price greater than 0.3 ETH.
/// @author 0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4 (abitwhaleish.eth)
/// @notice Ante Test to check the LlamaLend oracle used by the TubbyLoan
///         pool never returns a Tubby Cats price greater than 0.3 ETH
contract AnteLlamaLendOraclePriceV06Test is
    AnteTest("LlamaLend oracle never returns Tubby Cats price > 0.3 ETH (V06)")
{
    struct Message {
        bytes32 hash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // https://etherscan.io/address/0x34d0A4B1265619F3cAa97608B621a17531c5626f
    ILendingPool public constant LLAMALEND_TUBBYLOAN_POOL = ILendingPool(0x34d0A4B1265619F3cAa97608B621a17531c5626f);

    // https://etherscan.io/address/0xCa7cA7BcC765F77339bE2d648BA53ce9c8a262bD
    address public constant TUBBY_CATS = 0xCa7cA7BcC765F77339bE2d648BA53ce9c8a262bD;

    // The price that we don't think the oracle should return above
    uint256 public constant FAILURE_PRICE = 3e17; // 0.3 ETH

    // Message storage variable
    Message public message;

    constructor() {
        protocolName = "LlamaLend";
        testedContracts = [address(LLAMALEND_TUBBYLOAN_POOL), LLAMALEND_TUBBYLOAN_POOL.oracle()];
    }

    function getStateTypes() external pure override returns (string memory) {
        return "uint216,uint256,uint8,bytes32,bytes32";
    }

    function getStateNames() external pure override returns (string memory) {
        return "price,deadline,v,r,s";
    }

    /// @notice Checks if a valid message with a Tubby Cats price higher than
    ///         the failure threshold has been signed by the oracle. Requires
    ///         message parameters to be set using setMessageToCheck prior to
    ///         calling checkTestPasses.
    /// @return true if the message state set matches a valid message signed
    ///         by the oracle
    function checkTestPasses() public view override returns (bool) {
        // Check the oracle address
        address oracle = LLAMALEND_TUBBYLOAN_POOL.oracle();
        require(oracle != address(0), "Invalid oracle address");

        // Determine the address of the signed message contents set. We don't
        // use ECDSA.recover() because that will revert on error
        (address signer, ECDSA.RecoverError error) = ECDSA.tryRecover(message.hash, message.v, message.r, message.s);
        // If unsuccessful recovery, don't revert, just exit
        if (error != ECDSA.RecoverError.NoError) return true;

        // If signer == oracle, then a valid message with price higher than
        // the threshold has been signed by the oracle and the test fails
        return signer != oracle;
    }

    function _setState(bytes memory _state) internal override {
        /// @notice Sets the message parameters to check for a valid signature. As
        ///         of 2022-12-07, the following API endpoint can be used to get
        ///         the latest signed message from the Tubby Cats price oracle:
        ///         https://oracle.llamalend.com/quote/1/0xca7ca7bcc765f77339be2d648ba53ce9c8a262bd
        /// price     - floor price of collection
        /// deadline  - deadline of floor price validity
        /// v         - part of the message signature
        /// r         - part of the message signature
        /// s         - part of the message signature
        (uint216 price, uint256 deadline, uint8 v, bytes32 r, bytes32 s) = abi.decode(
            _state,
            (uint216, uint256, uint8, bytes32, bytes32)
        );
        // We only care if the price we're checking is above the failure level
        // of the test. Also, no need to check _deadline as we just care if the
        // oracle has ever returned a price too high, but we need to collect it
        // so we can generate the correct message body to match
        require(price > FAILURE_PRICE, "Price not above failing level!");

        // Store the hashed message body and signature to check
        message = Message(
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n111", price, deadline, block.chainid, TUBBY_CATS)
            ),
            v,
            r,
            s
        );
    }
}
