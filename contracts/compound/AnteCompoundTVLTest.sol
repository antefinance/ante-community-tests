// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface ICToken {
    function getCash() external view returns (uint256);

    function totalBorrows() external view returns (uint256);
}

/// @title Compound markets do not lose 90% of their assets test
/// @notice Ante Test to check that the total assets in each of Compound's top 5 markets
/// does not drop by 90%
contract AnteCompoundTVLTest is AnteTest("Compound Markets TVL Drop Test") {
    // top 5 markets on compound by $ value
    ICToken[5] public cTokens = [
        ICToken(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5), // cETH
        ICToken(0x39AA39c021dfbaE8faC545936693aC917d5E7563), // cUSDC
        ICToken(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643), // cDAI
        ICToken(0xccF4429DB6322D5C611ee964527D42E5d685DD6a), // cWBTC
        ICToken(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9) // cUSDT
    ];

    // threshold amounts by market
    uint256[5] public thresholds;

    /// @notice percent drop threshold (set to 10%)
    uint256 public constant PERCENT_DROP_THRESHOLD = 10;

    constructor() {
        protocolName = "Compound";

        for (uint256 i = 0; i < 5; i++) {
            ICToken cToken = cTokens[i];
            testedContracts.push(address(cToken));

            thresholds[i] = ((cToken.getCash() + cToken.totalBorrows()) * PERCENT_DROP_THRESHOLD) / 100;
        }
    }

    /// @notice checks compound TVL in top 5 markets
    /// @return true if TVL in all top 5 markets has not dropped by 90%, false if it has in at least one
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < 5; i++) {
            ICToken cToken = cTokens[i];
            if ((cToken.getCash() + cToken.totalBorrows()) < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
