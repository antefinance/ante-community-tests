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

import "../libraries/ante-v05-avax/AnteTest.sol";

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

/// @title  Alkimiya V2 BTC oracle never goes >72 hrs without an update
/// @notice Ante Test to check that no more than 72 hours has passed since
///         the last oracle update
contract AnteAlkimiyaV2BTCOracleLivenessTestAvax is
    AnteTest("Alkimiya V2 BTC oracle never goes >72 hrs without an update")
{
    // https://snowtrace.io/address/0x444a5880EbDaaaa14F942b6F71b39ffe8d4cEF93 on Avax Fuji testnet
    IOracle internal oracle;

    constructor(address _oracleAddress) {
        oracle = IOracle(_oracleAddress);

        protocolName = "Alkimiya"; // <3
        testedContracts = [_oracleAddress];
    }

    /// @notice Checks that the last update for the Alkimiya V2 BTC oracle was
    ///         at most 72 hours ago
    /// @return true if it has been less than 72 hours since the last oracle update
    function checkTestPasses() external view override returns (bool) {
        // get timestamp of last update
        (, , , , , , uint256 timestamp) = oracle.get(oracle.getLastIndexedDay());

        // assume that timestamp <= block.timestamp
        return block.timestamp - timestamp < 72 hours;
    }
}
