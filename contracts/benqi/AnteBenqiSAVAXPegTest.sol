// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface IOneInchOracle {
    function getRate(
        address srcToken,
        address dstToken,
        bool useWrapper
    ) external view returns (uint256);
}

/**
 * @dev Partial Interface of the Staked AVAX token.
 */
interface IStakedAVAX {
    /**
     * @dev Returns the total amount of AVAX controlled by the sAVAX contract.
     */
    function totalPooledAvax() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
}

/// @title BENQI Staked AVAX Peg Test
/// @notice Test if the sAVAX price pegs to formula
/// sAVAX Price = (total AVAX staked / total sAVAX minted * AVAX price) +/- 5%
contract AnteBenqiSAVAXPegTest is AnteTest("sAVAX maintains peg +/- 5% to AVAX") {
    IOneInchOracle private oneInchOracle = IOneInchOracle(0xBd0c7AaF0bF082712EbE919a9dD94b2d978f79A9);

    address private constant WAVAX_ADDRESS = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address private constant SAVAX_ADDRESS = 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE;
    address private constant USDC_ADDRESS = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;

    uint256 public preCheckBlock = 0;
    uint256 public preCheckSlip = 0;

    constructor() {
        protocolName = "BENQI Finance";
        testedContracts = [SAVAX_ADDRESS];
    }

    /// @notice Used to prevent flash loan attacks
    function preCheck() external {
        uint256 savaxToUsdc = oneInchOracle.getRate(SAVAX_ADDRESS, USDC_ADDRESS, false);
        uint256 avaxToUsdc = oneInchOracle.getRate(WAVAX_ADDRESS, USDC_ADDRESS, false);

        uint256 savaxCalculatedPrice = ((IStakedAVAX(SAVAX_ADDRESS).totalPooledAvax() * 100) /
            IStakedAVAX(SAVAX_ADDRESS).totalSupply()) * avaxToUsdc;

        preCheckBlock = block.number;
        preCheckSlip = savaxCalculatedPrice / savaxToUsdc;
    }

    /// @notice Must be called after 20 blocks after preCheck()
    /// @return true if the peg is within 5%
    function checkTestPasses() public view override returns (bool) {
        if (preCheckBlock == 0 || preCheckSlip == 0 || block.number - preCheckBlock < 20) {
            return true;
        }

        uint256 savaxToUsdc = oneInchOracle.getRate(SAVAX_ADDRESS, USDC_ADDRESS, false);
        uint256 avaxToUsdc = oneInchOracle.getRate(WAVAX_ADDRESS, USDC_ADDRESS, false);

        uint256 savaxCalculatedPrice = ((IStakedAVAX(SAVAX_ADDRESS).totalPooledAvax() * 100) /
            IStakedAVAX(SAVAX_ADDRESS).totalSupply()) * avaxToUsdc;

        uint256 slip = savaxCalculatedPrice / savaxToUsdc;

        // If each slippage test was within 5% of the preCheckSlip, then the test passes
        return (slip > 95 && slip < 105) || (preCheckSlip > 95 && preCheckSlip < 105);
    }

    /// @return true if the test will work properly (e.g. preCheck() was called 20 blocks prior)
    function willTestWork() public view returns (bool) {
        return !(preCheckSlip == 0 || preCheckBlock == 0 || block.number - preCheckBlock < 20);
    }
}
