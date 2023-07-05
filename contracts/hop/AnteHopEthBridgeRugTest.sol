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

/// @title Hop Ethereum Bridge doesn't rug test on mainnet
/// @author 0xa0e7Fb16cdE37Ebf2ceD6C89fbAe8780B8497e12
/// @notice Ante Test to check if Hop Ethereum Bridge rugs
contract AnteHopEthBridgeRugTest is AnteTest("EOA Avalanche Bridge Doesnt Rug 99% of its Value Test") {
    // https://etherscan.io/address/0xb8901acb165ed027e32754e0ffe830802919727f
    address public constant hopEthBridgeAddr = 0xb8901acB165ed027E32754E0FFe830802919727f;

    uint256 public immutable etherBalanceAtDeploy;

    constructor() {
        protocolName = "Hop Protocol";
        testedContracts = [hopEthBridgeAddr];

        etherBalanceAtDeploy = hopEthBridgeAddr.balance;
    }

    /// @notice test to check value of ether is not rugged
    /// @return true if bridge has more than 1% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return (etherBalanceAtDeploy / 100) < hopEthBridgeAddr.balance)
    }
}
