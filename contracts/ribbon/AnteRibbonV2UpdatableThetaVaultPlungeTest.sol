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
import {IRibbonThetaVault} from "./ribbon-v2-contracts/interfaces/IRibbonThetaVault.sol";
import {IController, GammaTypes} from "./ribbon-v2-contracts/interfaces/GammaInterface.sol";
import {Vault} from "./ribbon-v2-contracts/libraries/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Checks that RibbonV2 Theta Vaults do not lose 90% of their assets
/// @notice Ante Test to check if a catastrophic failure has occured in RibbonV2
contract AnteRibbonV2UpdatableThetaVaultPlungeTest is Ownable, AnteTest("RibbonV2 Theta Vaults don't lose 90% of TVL") {
    /// @notice Emitted when test owner updates test vaults/thresholds
    /// @param vault The address of vault
    /// @param threshold new failure threshold
    event AnteRibbonTestUpdated(address indexed vault, uint256 threshold);

    // major active RibbonV2 theta vaults
    IRibbonThetaVault[] public thetaVaults = [
        IRibbonThetaVault(0x53773E034d9784153471813dacAFF53dBBB78E8c), // T-STETH-C vault
        IRibbonThetaVault(0x25751853Eab4D0eB3652B5eB6ecB102A2789644B), // T-ETH-C vault
        IRibbonThetaVault(0xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624), // T-USDC-P-ETH vault
        IRibbonThetaVault(0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F) // T-WBTC-C vault
    ];

    // Opyn Controller
    IController internal controller = IController(0x4ccc2339F87F6c59c6893E1A678c2266cA58dC72);

    // threshold asset balance for test to fail (will set in constructor)
    uint256[] public thresholds = [0, 0, 0, 0];

    /// @notice percent drop threshold (set to 10%)
    uint8 public constant PERCENT_DROP_THRESHOLD = 10;

    // last timestamp test parameters were updated
    uint256 public lastUpdated;

    /// @notice minimum time between test updates by owner
    uint256 public constant UPDATE_TIMELOCK = 86400; // 1 day
    uint256 public constant REMOVE_TIMELOCK = 604800; // 7 days
    uint256 public constant MAX_VAULTS = 20; // to guard against block stuffing

    constructor() {
        protocolName = "Ribbon";
        for (uint256 i; i < thetaVaults.length; i++) {
            thresholds[i] = (calculateAssetBalance(thetaVaults[i]) * PERCENT_DROP_THRESHOLD) / 100;
            testedContracts.push(address(thetaVaults[i]));
        }
        lastUpdated = block.timestamp;
    }

    /// @notice Add a Ribbon Theta Vault to test and set failure threshold
    ///         to 10% of current TVL. Can only be called by owner (Ribbon)
    /// @param _vault Ribbon V2 Theta Vault address to add
    function addVault(address _vault) public onlyOwner {
        require(block.timestamp > lastUpdated + UPDATE_TIMELOCK, "Need to wait 1 day between updates!");
        require(thetaVaults.length < MAX_VAULTS, "Maximum number of tested vaults reached!");

        // Assume that owner does not add an invalid or duplicate vault
        // (in which case if either threshold fails the whole test fails)
        IRibbonThetaVault vault = IRibbonThetaVault(_vault);
        uint256 threshold = (calculateAssetBalance(vault) * PERCENT_DROP_THRESHOLD) / 100;

        thetaVaults.push(vault);
        thresholds.push(threshold);
        testedContracts.push(address(vault));
        lastUpdated = block.timestamp;

        emit AnteRibbonTestUpdated(address(vault), threshold);
    }

    function sunsetVault(uint256 index) public onlyOwner {
        require(block.timestamp > lastUpdated + REMOVE_TIMELOCK, "Need 7 days to sunset vault");
        require(index < thetaVaults.length, "Index out of bounds");
        // require vault is not already failing
        require(calculateAssetBalance(thetaVaults[index]) >= thresholds[index], "vault already failing");

        thresholds[index] = 0;
        lastUpdated = block.timestamp;

        emit AnteRibbonTestUpdated(address(thetaVaults[index]), 0);
    }

    /// @notice Reset TVL failure threshold for a single vault to 10% of
    ///         current TVL. Can only be called by owner (Ribbon)
    /// @param index array index of vault to reset TVL threshold for
    function resetThreshold(uint256 index) public onlyOwner {
        require(index < thetaVaults.length, "Index out of bounds");
        require(block.timestamp > lastUpdated + UPDATE_TIMELOCK, "Need to wait 1 day between updates!");

        thresholds[index] = (calculateAssetBalance(thetaVaults[index]) * PERCENT_DROP_THRESHOLD) / 100;
        lastUpdated = block.timestamp;

        emit AnteRibbonTestUpdated(address(thetaVaults[index]), thresholds[index]);
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
    function checkTestPasses() external view override returns (bool) {
        for (uint256 i; i < thetaVaults.length; i++) {
            if (calculateAssetBalance(thetaVaults[i]) < thresholds[i]) {
                return false;
            }
        }

        return true;
    }
}
