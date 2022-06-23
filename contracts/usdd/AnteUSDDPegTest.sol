// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IOneInchOracle {
    function getRate(
        address srcToken,
        address dstToken,
        bool useWrapper
    ) external view returns (uint256);
}

/// @title USDD Avalanche Peg Test
/// @notice Ensure that USDD maintains peg to +/- 5%
contract AnteUSDDPegTest is AnteTest("Ensure that USDD maintains peg to +/- 5%") {
    IOneInchOracle private oneInchOracle = IOneInchOracle(0xBd0c7AaF0bF082712EbE919a9dD94b2d978f79A9);

    address private constant USDD_ADDRESS = 0xcf799767d366d789e8B446981C2D578E241fa25c;

    constructor() {
        protocolName = "USDD";
        testedContracts = [USDD_ADDRESS];
    }

    uint256 public preCheckBlock = 0;
    uint256 public preCheckSlip = 0;

    constructor() {
        protocolName = "Convex";
        testedContracts = [CURVE_ADDRESS, CVX_CURVE_ADDRESS];
    }

    /// @notice Used to prevent flash loan attacks
    function preCheck() external {
        uint256 crvToETH = oneInchOracle.getRate(CURVE_ADDRESS, WETH_ADDRESS, false);
        uint256 cvxCRVToETH = oneInchOracle.getRate(CVX_CURVE_ADDRESS, WETH_ADDRESS, false);

        preCheckBlock = block.number;
        preCheckSlip = (crvToETH * 100) / cvxCRVToETH;
    }

    /// @notice Must be called after 20 blocks after preCheck()
    /// @return true if the peg is within 4%
    function checkTestPasses() external view override returns (bool) {
        uint256 crvToETH = oneInchOracle.getRate(CURVE_ADDRESS, WETH_ADDRESS, false);
        uint256 cvxCRVToETH = oneInchOracle.getRate(CVX_CURVE_ADDRESS, WETH_ADDRESS, false);

        if (preCheckBlock == 0 || preCheckSlip == 0) {
            return true;
        }

        if (block.number - preCheckBlock < 20) {
            return true;
        }

        uint256 slip = (crvToETH * 100) / cvxCRVToETH;

        // If each slippage test was within 10% of the preCheckSlip, then the test passes
        if ((slip < 105 && slip > 95) && (preCheckSlip < 105 && preCheckSlip > 95)) {
            return true;
        }

        return false;
    }
}
