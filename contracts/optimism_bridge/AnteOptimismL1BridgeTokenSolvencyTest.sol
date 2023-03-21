// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface L1StandardBridge {
    function deposits(address _l1Token, address _l2Token) external view returns (uint256);
}

/// @title Optimism L1 Bridge token holdings match internal accounting
/// @notice Ante Test to check if Optimism Bridge contracts owns at least as many tokens as have been deposited
contract AnteOptimismL1BridgeTokenSolvencyTest is AnteTest("Optimism L1 Bridge token accounting is solvent") {
    // https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1
    address public constant optimismL1BridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;

    struct TokenBridgePair {
        address l1Token;
        address l2Token;
    }

    // Top 6 tokens
    TokenBridgePair[] public tokens;

    constructor() {
        protocolName = "Optimism Bridge";
        testedContracts = [optimismL1BridgeAddr];

        // Optimism officially supported L2 token addresses extracted from
        // https://github.com/ethereum-optimism/ethereum-optimism.github.io/blob/master/optimism.tokenlist.json

        // Top assets extracted from
        //https://etherscan.io/tokenholdings?a=0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1

        // USDC
        _addTokenPair(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0x7F5c764cBc14f9669B88837ca1490cCa17c31607);

        // USDT
        _addTokenPair(0xdAC17F958D2ee523a2206206994597C13D831ec7, 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58);

        // WBTC
        _addTokenPair(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, 0x68f180fcCe6836688e9084f035309E29Bf0A2095);

        // Lyra
        _addTokenPair(0x01BA67AAC7f75f647D94220Cc98FB30FCc5105Bf, 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb);

        //Dola
        _addTokenPair(0x865377367054516e17014CcdED1e7d814EDC9ce4, 0x8aE125E8653821E851F12A49F7765db9a9ce7384);

        //rETH
        _addTokenPair(0xae78736Cd615f374D3085123A210448E74Fc6393, 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D);
    }

    function _addTokenPair(address _l1TokenAddress, address _l2TokenAddress) private {
        tokens.push(TokenBridgePair({l1Token: _l1TokenAddress, l2Token: _l2TokenAddress}));
        testedContracts.push(_l1TokenAddress);
    }

    /// @notice test to check the solvency of top 6 assets on Optimism Bridge
    /// @return true if bridge owns at least as many tokens as were deposited
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 depositedAmount = L1StandardBridge(optimismL1BridgeAddr).deposits(
                tokens[i].l1Token,
                tokens[i].l2Token
            );

            if (IERC20(tokens[i].l1Token).balanceOf(optimismL1BridgeAddr) < depositedAmount) {
                return false;
            }
        }
        return true;
    }
}
