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
import "./ribbon-v2-contracts/interfaces/IRibbonThetaVault.sol";
import "./opyn/IMarginPool.sol";

import {Vault} from "./ribbon-v2-contracts/libraries/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Checks that RibbonV2 vaults do not lose 90% of their assets
/// @notice Ante Test to check if a catastrophic failure has occured in RibbonV2
contract AnteRibbonRugTest is AnteTest("RibbonV2 doesn't lose 90% of its TVL") {
    // currently deployed RibbonV2 theta vaults
    IRibbonThetaVault[] public thetaVaults = [
        IRibbonThetaVault(0x25751853Eab4D0eB3652B5eB6ecB102A2789644B), // eth vault
        IRibbonThetaVault(0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F) // wbtc vault
    ];

    // Opyn MarginPool
    MarginPoolInterface public marginPool = MarginPoolInterface(0x5934807cC0654d46755eBd2848840b616256C6Ef);

    // threshold amounts for test to fail
    uint256[] public thresholds;

    /// @notice percent drop threshold (set to 10%)
    uint8 public constant PERCENT_DROP_THRESHOLD = 10;

    constructor() {
        protocolName = "Ribbon";
        for (uint256 i; i < thetaVaults.length; i++) {
            thresholds[i] = (calculateAssetBalance(thetaVaults[i]) * PERCENT_DROP_THRESHOLD) / 100;
        }
    }

    function calculateAssetBalance(IRibbonThetaVault vault) public view returns (uint256) {
        Vault.VaultParams memory vaultParams = vault.vaultParams();
        Vault.VaultState memory vaultState = vault.vaultState();
        IERC20 underlying = IERC20(vaultParams.underlying);

        // TODO: see if there is a way to get the minted oTokens or collateral from the MarginPool
        // Controller, or EasyAuction so we are not relying on theta vault to be honest
        return underlying.balanceOf(address(vault)) + vaultState.lockedAmount;
    }

    function checkTestPasses() external view override returns (bool) {
        for (uint256 i; i < thetaVaults.length; i++) {
            if (calculateAssetBalance(thetaVaults[i]) < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
