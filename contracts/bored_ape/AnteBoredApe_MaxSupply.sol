// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface BoredApes {
    //TODO: silence linter (variable must be mixedCase)
    function MAX_APES() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

/// @title AnteBoredApeMaxSupplyTest
/// @notice Ensure that minted BAYC tokens are less than or equal 10,000 as advertised
contract AnteBoredApeMaxSupplyTest is AnteTest("Ensure that BAYC token supply is capped at 10,000") {
    // https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    address public constant BAYC_ADDR = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    BoredApes public constant BAYC_CONTRACT = BoredApes(BAYC_ADDR);

    /**
     * Network: Mainnet
     * Address: 0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
     */
    constructor() {
        protocolName = "BAYC";
        testedContracts = [BAYC_ADDR];
    }

    /// @return if the BAYC supply <= max tokens (10,000)
    function checkTestPasses() public view override returns (bool) {
        return (BAYC_CONTRACT.totalSupply() <= BAYC_CONTRACT.MAX_APES());
    }
}
