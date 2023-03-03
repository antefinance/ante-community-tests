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

import {AnteTest} from "../libraries/ante-v05-avax/AnteTest.sol";
import {IRibbonThetaVault} from "./ribbon-v2-contracts/interfaces/IRibbonThetaVault.sol";
import {IController, GammaTypes} from "./ribbon-v2-contracts/interfaces/GammaInterface.sol";
import {Vault} from "./ribbon-v2-contracts/libraries/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Checks that RibbonV2 Theta vaults do not lose 90% of their assets
/// @notice Ante Test to check if a catastrophic failure has occured in RibbonV2
contract AnteRibbonV2ThetaVaultPlungeTest is AnteTest("RibbonV2 doesn't lose 90% of its TVL") {
    // currently deployed RibbonV2 theta vaults
    IRibbonThetaVault[2] public thetaVaults = [
        IRibbonThetaVault(0x25751853Eab4D0eB3652B5eB6ecB102A2789644B), // eth vault
        IRibbonThetaVault(0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F) // wbtc vault
    ];

    // Opyn Controller
    IController internal controller = IController(0x4ccc2339F87F6c59c6893E1A678c2266cA58dC72);

    // threshold amounts for test to fail
    uint256[2] public thresholds;

    /// @notice percent drop threshold (set to 10%)
    uint8 public constant PERCENT_DROP_THRESHOLD = 10;

    constructor() {
        protocolName = "Ribbon";
        for (uint256 i; i < thetaVaults.length; i++) {
            thresholds[i] = (calculateAssetBalance(thetaVaults[i]) * PERCENT_DROP_THRESHOLD) / 100;
            testedContracts.push(address(thetaVaults[i]));
        }
    }

    /// @notice computes balance of underlying asset in a given Ribbon Theta Vault
    /// @param vault RibbonV2 Theta Vault address
    /// @return balance of vault
    function calculateAssetBalance(IRibbonThetaVault vault) public view returns (uint256) {
        Vault.VaultParams memory vaultParams = vault.vaultParams();
        IERC20 underlying = IERC20(vaultParams.underlying);

        GammaTypes.Vault memory opynVault = controller.getVault(
            address(vault),
            controller.getAccountVaultCounter(address(vault))
        );

        // make assumption that there is only one collateral asset in vault
        return underlying.balanceOf(address(vault)) + opynVault.collateralAmounts[0];
    }

    /// @notice checks balance of Ribbon Theta V2 vaults against threshold
    /// (10% of balance when this contract was deployed)
    /// @return true if balance of all theta vaults is greater than thresholds
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i; i < thetaVaults.length; i++) {
            if (calculateAssetBalance(thetaVaults[i]) < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
