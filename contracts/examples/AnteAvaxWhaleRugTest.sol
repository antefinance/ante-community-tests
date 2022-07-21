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

import {AnteTest} from "../AnteTest.sol";

/// @title Avalanche wallet address 0xd497...e49c doesn't rug test
/// @notice Ante Test to check if Avalanche wallet "rugs" 90% of its AVAX as of deployment
contract AnteAvaxWhaleRugTest is AnteTest("Avalanche Address 0xd497...e49c Doesnt Rug 90% of its AVAX") {
    // https://snowtrace.io/address/0x0d4975357baf74b76b8de887306afd9b8416e49c
    address public immutable avaxWhaleAddr;

    uint256 public immutable avaxBalanceAtDeploy;

    /// @param _avaxWhaleAddr address (0x0d4975357baf74b76b8de887306afd9b8416e49c on avalanche c-chain)
    constructor(address _avaxWhaleAddr) {
        protocolName = "AVAX";
        testedContracts = [_avaxWhaleAddr];

        avaxWhaleAddr = _avaxWhaleAddr;
        avaxBalanceAtDeploy = avaxWhaleAddr.balance;
    }

    /// @notice test to check balance of avax whale
    /// @return true if AVAX has reduced to 10% or below of original deploy balance
    function checkTestPasses() external view override returns (bool) {
        return avaxWhaleAddr.balance * 10 >= avaxBalanceAtDeploy;
    }
}
