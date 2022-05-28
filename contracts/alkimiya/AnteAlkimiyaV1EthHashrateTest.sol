// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "../libraries/ante-v05-core/AnteTest.sol";
import "hardhat/console.sol";

interface IOracle {
    function get(uint256 _referenceDay)
        external
        view
        returns (
            uint256 referenceDay,
            uint256 referenceBlock,
            uint256 hashrate,
            uint256 reward,
            uint256 fees,
            uint256 difficulty,
            uint256 timestamp
        );

    function getLastIndexedDay() external view returns (uint32);
}

/// @title  Alkimiya V1 ETH oracle
/// @notice Ante Test to check that
///
contract AnteAlkimiyaV1EthHashrateTest is
    AnteTest("Alkimiya V1 ETH oracle returns reasonable hashrate for current block difficulty")
{
    // https://snowtrace.io/address/0x3cb3608bff641b55f8dbafe86afc91cd36a17185 on Avax C-Chain
    IOracle internal oracle;

    /// @notice percent drop threshold
    // According to Etherscan, since 2020-01-03, the average daily hashrate has
    // been between 0.0755-0.0812x the average daily difficulty (mean = 0.0787,
    // SD = 0.000916). A rudimentary 6-sigma limit for "black swan" type events
    // then gives us the range [0.07323841103, 0.08423440892]. We will simplify
    // this to [0.0732, 0.0842], stored as {MIN,MAX}_THRESHOLD / SCALING_FACTOR.
    // EDIT: currently using +/- 3 sigma for all time data until more analysis
    // since this gives a wider range.
    uint256 public constant MIN_THRESHOLD = 489;
    uint256 public constant MAX_THRESHOLD = 1008;
    uint256 public constant SCALING_FACTOR = 10000;

    constructor(address _oracleAddress) {
        oracle = IOracle(_oracleAddress);

        protocolName = "Alkimiya"; // <3
        testedContracts.push(_oracleAddress);
    }

    /// @notice Checks that as long as the Merge has not yet occurred, the
    ///         hashrate returned by the oracle is reasonable for the current
    ///         block difficulty
    /// @return true if hashrate is within 6SD of historical hashrate variation
    ///         based on current block difficulty OR the Merge has occurred
    function checkTestPasses() external view override returns (bool) {
        // Check if the merge has occurred -- if so, return true (oracle no longer relevant)
        if (block.difficulty > 2**64 || block.difficulty == 0) {
            return true;
        }

        // get most recent hashrate from oracle
        (, , uint256 hashrate, , , , ) = oracle.get(oracle.getLastIndexedDay());

        console.log("difficulty: ", block.difficulty);
        console.log("hashrate:   ", hashrate);
        console.log("range: ", block.difficulty * MIN_THRESHOLD, "-", block.difficulty * MAX_THRESHOLD);
        console.log("value: ", hashrate * SCALING_FACTOR);

        // See above for threshold assumptions
        // We are checking:
        // difficulty * MIN_THRESHOLD / SCALING_FACTOR <= hashrate <= difficulty * MAX_THRESHOLD / SCALING_FACTOR
        // difficulty * MIN_THRESHOLD <= hashrate * SCALING_FACTOR <= difficulty * MAX_THRESHOLD
        return
            (hashrate * SCALING_FACTOR >= block.difficulty * MIN_THRESHOLD) &&
            (hashrate * SCALING_FACTOR <= block.difficulty * MAX_THRESHOLD);
    }
}
