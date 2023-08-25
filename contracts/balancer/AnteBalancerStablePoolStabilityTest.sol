// SPDX-License-Identifier: MIT

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
import "../interfaces/IERC20.sol";

interface IBalancerVaultV2 {
    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangedBlock
        );
}

/// @title Balancer Stable Pool Stability Test
/// @notice Ensure that each token in the pool makes about 30% +/- 3%
contract AnteBalancerStablePoolStabilityTest is AnteTest("Balancer stable pool remains balanced +/- 3%") {
    address private constant BALANCER_VAULT_ADDRESS = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    bytes32 private immutable stablePoolID;

    IBalancerVaultV2 private constant BALANCER_VAULT = IBalancerVaultV2(BALANCER_VAULT_ADDRESS);

    address[] private tokenAddresses;
    uint256[] private tokenDecimals;

    IERC20[] private tokens;

    /// @param _stablePoolID The stable pool ID to test
    constructor(bytes32 _stablePoolID) {
        protocolName = "BalancerV2";
        testedContracts = [BALANCER_VAULT_ADDRESS];

        stablePoolID = _stablePoolID;

        (tokenAddresses, , ) = BALANCER_VAULT.getPoolTokens(stablePoolID);

        for (uint8 i = 0; i < tokenAddresses.length; i++) {
            tokens.push(IERC20(tokenAddresses[i]));
            tokenDecimals.push(tokens[i].decimals());
        }
    }

    /// @notice In the rare case that the vault returns values in a different order than at deployment,
    /// this function can be use to call it
    function reorder() external {
        (tokenAddresses, , ) = BALANCER_VAULT.getPoolTokens(stablePoolID);

        delete tokens;
        delete tokenDecimals;

        for (uint8 i = 0; i < tokenAddresses.length; i++) {
            tokens.push(IERC20(tokenAddresses[i]));
            tokenDecimals.push(tokens[i].decimals());
        }
    }

    /// @notice In a rare care a challenger may have to call reorder() if the vault returns values in a
    /// different order than at deployment.
    /// @return true if the pool is stable with a 3% tolerance
    function checkTestPasses() public view override returns (bool) {
        uint256 adjustToDecimals = 9999999;
        for (uint8 i = 0; i < tokenDecimals.length; i++) {
            if (tokenDecimals[i] < adjustToDecimals) {
                adjustToDecimals = tokenDecimals[i];
            }
        }

        uint256[] memory balances;
        address[] memory _tokens;

        (_tokens, balances, ) = BALANCER_VAULT.getPoolTokens(stablePoolID);

        // Check if the token orders now and from contract deployment are the same
        // The reason we do this and not just redefine everything per call is due to
        // gas costs and view functions having limitations with .push()
        //
        // If anything doesn't match, abort the test and return true.
        // Challenger will have to call the reorder() function
        for (uint8 i = 0; i < _tokens.length; i++) {
            if (tokenAddresses[i] != _tokens[i]) {
                revert("ERROR: Please call reorder() function");
            }
        }

        // At this point we know that the orders are the same.
        // Time to adjust the balances to the correct decimals
        for (uint8 i = 0; i < balances.length; i++) {
            uint256 decimalDifference = tokenDecimals[i] - adjustToDecimals;

            balances[i] = balances[i] / (10**decimalDifference);
        }

        uint256 totalValue = 0;
        for (uint8 i = 0; i < balances.length; i++) {
            totalValue += balances[i];
        }

        for (uint8 i = 0; i < balances.length; i++) {
            if (!ratioValid(totalValue, balances[i], balances.length)) {
                return false;
            }
        }

        return true;
    }

    /// @param totalValue The total value of the pool
    /// @param share The amount of token in the pool
    /// @param amountOfTokens the amount of different type of tokens in the pool
    /// @return true if the ratio is within 3% of the expected ratio
    function ratioValid(
        uint256 totalValue,
        uint256 share,
        uint256 amountOfTokens
    ) public pure returns (bool) {
        uint256 expectedRatio = 100 / amountOfTokens;
        uint256 ratio = (100 * share) / totalValue;

        if (ratio < expectedRatio - 3 || ratio > expectedRatio + 3) {
            return false;
        }

        return true;
    }
}
