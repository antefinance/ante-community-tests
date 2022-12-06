// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {LendingPool} from "./llamalend-contracts/LendingPool.sol";

/// @title Checks that asdf
/// @author abitwhaleish.eth
/// @notice Ante Test to check
contract AnteLlamaLendOraclePriceTest is AnteTest("LlamaLend Oracle never returns price > 1 ETH for Tubby Cats") {
    // https://etherscan.io/address/0x34d0A4B1265619F3cAa97608B621a17531c5626f
    LendingPool public constant LLAMALEND_TUBBY_CAT_POOL = LendingPool(0x34d0A4B1265619F3cAa97608B621a17531c5626f);

    // https://etherscan.io/address/0xCa7cA7BcC765F77339bE2d648BA53ce9c8a262bD
    address public constant TUBBY_CATS = 0xCa7cA7BcC765F77339bE2d648BA53ce9c8a262bD;

    uint256 public failurePrice;
    uint256 internal price;
    uint256 internal deadline;
    uint8 internal v;
    bytes32 internal r;
    bytes32 internal s;

    constructor() {
        failurePrice = 1e18; // 1 eth

        protocolName = "LlamaLend";
        testedContracts = [address(LLAMALEND_TUBBY_CAT_POOL)];
    }

    // function to set state to check?
    function setMessageToCheck(
        uint216 _price,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(price > failurePrice, "price not above failing level!");
        // no need to check deadline as we are checking if the Oracle has
        // ever returned a price too high, not just recently
        price = _price;
        deadline = _deadline;
        v = _v;
        r = _r;
        s = _s;
    }

    /// @notice checks if
    /// @return true if
    function checkTestPasses() public view override returns (bool) {
        address oracle = LLAMALEND_TUBBY_CAT_POOL.oracle();
        if (oracle == address(0)) return true; // no oracle, don't fail the test!

        (address signer, ECDSA.RecoverError error) = ECDSA.tryRecover(
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n111", price, deadline, block.chainid, TUBBY_CATS)
            ),
            v,
            r,
            s
        );
        // don't revert if unable to recover address!
        if (error != ECDSA.RecoverError.NoError) return true;

        // If signer == oracle, then a valid oracle message with a price
        // higher than the threshold has been submitted and the test fails
        return signer != oracle;
    }
}
