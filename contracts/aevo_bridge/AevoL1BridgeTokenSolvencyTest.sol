// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IL1StandardBridge {
    function deposits(address _l1Token, address _l2Token) external view returns (uint256);
}

/// @title Aevo L1 Bridge token holdings match internal accounting
/// @notice Ante Test to check if Aevo Bridge contracts owns at least as many tokens as have been deposited
contract AevoL1BridgeTokenSolvencyTest is AnteTest("Aevo L1 Bridge token accounting is solvent") {
    // https://etherscan.io/address/0x4082C9647c098a6493fb499EaE63b5ce3259c574
    address public constant aevoL1BridgeAddr = 0x4082C9647c098a6493fb499EaE63b5ce3259c574;

    struct TokenBridgePair {
        address l1Token;
        address l2Token;
    }

    TokenBridgePair[] public tokens;

    constructor() {
        protocolName = "Aevo Bridge";
        testedContracts = [aevoL1BridgeAddr];

        // Top assets extracted from
        //https://etherscan.io/tokenholdings?a=0x4082C9647c098a6493fb499EaE63b5ce3259c574

        // USDC
        _addTokenPair(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0x643aaB1618c600229785A5E06E4b2d13946F7a1A);
    }

    function _addTokenPair(address _l1TokenAddress, address _l2TokenAddress) private {
        tokens.push(TokenBridgePair({l1Token: _l1TokenAddress, l2Token: _l2TokenAddress}));
        testedContracts.push(_l1TokenAddress);
    }

    /// @notice test to check the solvency of top 6 assets on Optimism Bridge
    /// @return true if bridge owns at least as many tokens as were deposited
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 depositedAmount = IL1StandardBridge(aevoL1BridgeAddr).deposits(
                tokens[i].l1Token,
                tokens[i].l2Token
            );

            if (IERC20(tokens[i].l1Token).balanceOf(aevoL1BridgeAddr) < depositedAmount) {
                return false;
            }
        }
        return true;
    }
}
