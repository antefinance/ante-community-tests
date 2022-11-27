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
import "hardhat/console.sol";

/// @title Checks that RibbonV2 Theta Vaults do not lose 90% of their assets
/// @notice Ante Test to check if a catastrophic failure has occured in RibbonV2
contract AnteRibbonV2UpdatableThetaVaultPlungeTest is Ownable, AnteTest("RibbonV2 Theta Vaults don't lose 90% of TVL") {
    /// @notice Emitted when test owner adds a vault to check
    /// @param vault The address of the vault added
    /// @param vaultAsset The address of the ERC20 token used by the vault
    event AnteRibbonTestVaultAdded(address indexed vault, address vaultAsset);

    /// @notice Emitted when test owner commits a failure thresholds update
    /// @param vault The address of vault
    /// @param oldThreshold old failure threshold
    /// @param newThreshold new failure threshold
    event AnteRibbonTestPendingUpdate(address indexed vault, uint256 oldThreshold, uint256 newThreshold);

    /// @notice Emitted when test owner updates test vaults/thresholds
    /// @param vault The address of vault
    /// @param oldThreshold old failure threshold
    /// @param newThreshold new failure threshold
    event AnteRibbonTestUpdated(address indexed vault, uint256 oldThreshold, uint256 newThreshold);

    uint256 public constant MAX_VAULTS = 20; // to guard against block stuffing

    // major active RibbonV2 theta vaults
    address[] public thetaVaults = [
        0x53773E034d9784153471813dacAFF53dBBB78E8c, // T-STETH-C vault
        0x25751853Eab4D0eB3652B5eB6ecB102A2789644B, // T-ETH-C vault
        0xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624, // T-USDC-P-ETH vault
        0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F // T-WBTC-C vault
    ];

    // vault asset - since we cannot rely 100% on the Ribbon vault or the Opyn controller for this
    IERC20[] public assets = [
        IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84), // wstETH
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // WETH
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), // USDC
        IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599) // WBTC
    ];

    // Opyn Controller
    IController internal controller = IController(0x4ccc2339F87F6c59c6893E1A678c2266cA58dC72);

    // threshold asset balance for test to fail (will set in constructor)
    uint256[] public thresholds = [0, 0, 0, 0];

    /// @notice failure threshold as % of initial value (set to 10%)
    uint8 public constant FAILURE_PERCENT_THRESHOLD = 10;

    /// @notice minimum waiting period for major test updates by owner
    uint256 public constant UPDATE_FAILURE_WAITING_PERIOD = 172800; // 2 days

    // last timestamp test parameters were updated
    uint256 public lastUpdated;

    bool public pendingUpdate = false;
    uint256 public updateCommittedTime;
    uint256 public pendingVaultIndex;
    uint256 public newThreshold;

    constructor() {
        protocolName = "Ribbon";

        for (uint256 i; i < thetaVaults.length; i++) {
            thresholds[i] = (calculateAssetBalance(thetaVaults[i], assets[i]) * FAILURE_PERCENT_THRESHOLD) / 100;
            testedContracts.push(thetaVaults[i]);
        }
        lastUpdated = block.timestamp;
    }

    /// @notice checks balance of Ribbon Theta V2 vaults against threshold
    /// (10% of balance when this contract was deployed)
    /// @return true if balance of all theta vaults is greater than thresholds
    function checkTestPasses() external view override returns (bool) {
        for (uint256 i; i < thetaVaults.length; i++) {
            if (calculateAssetBalance(thetaVaults[i], assets[i]) < thresholds[i]) {
                return false;
            }
        }

        return true;
    }

    /// @notice computes balance of underlying asset in a given Ribbon Theta Vault
    /// @param thetaVault RibbonV2 Theta Vault address
    /// @return balance of vault
    function calculateAssetBalance(address thetaVault, IERC20 vaultAsset) public view returns (uint256) {
        GammaTypes.Vault memory opynVault = controller.getVault(
            thetaVault,
            controller.getAccountVaultCounter(thetaVault)
        );

        // Note: assumes 1 collateral asset max
        if (opynVault.collateralAssets.length == 1) {
            // TODO should we check that internal asset matches opyn asset as a sanity check?
            return vaultAsset.balanceOf(thetaVault) + opynVault.collateralAmounts[0];
        } else {
            // in between rounds, so collateralAmounts is null array
            return vaultAsset.balanceOf(thetaVault);
        }
    }

    // == ADMIN FUNCTIONS == //

    /// @notice Add a Ribbon Theta Vault to test and set failure threshold
    ///         to 10% of current TVL. Can only be called by owner (Ribbon)
    /// @param vault Ribbon V2 Theta Vault address to add
    function addVault(address vault, address _asset) public onlyOwner {
        // Checks max vaults + valid Opyn vault for the given theta vault address
        require(thetaVaults.length < MAX_VAULTS, "Maximum number of tested vaults reached!");
        GammaTypes.Vault memory opynVault = controller.getVault(vault, controller.getAccountVaultCounter(vault));
        require(opynVault.collateralAssets.length == 1, "Invalid vault");
        require(opynVault.collateralAssets[0] == _asset, "assets don't match!");

        IERC20 vaultAsset = IERC20(_asset);
        uint256 balance = calculateAssetBalance(vault, vaultAsset);
        require(balance > 0, "Vault has no balance!");

        uint256 threshold = (balance * FAILURE_PERCENT_THRESHOLD) / 100;

        thetaVaults.push(vault);
        assets.push(vaultAsset);
        thresholds.push(threshold);
        testedContracts.push(vault);
        lastUpdated = block.timestamp;

        emit AnteRibbonTestVaultAdded(vault, _asset);
    }

    /// @notice Propose a new vault failure threshold value and start waiting
    ///         period before update is made. Can only be called by owner (Ribbon)
    /// @param index array index of vault to reset TVL threshold for
    /// @param threshold to set (in opyn vault collateral asset with decimals)
    function commitUpdateFailureThreshold(uint256 index, uint256 threshold) public onlyOwner {
        require(index < thetaVaults.length, "Index out of bounds");
        require(!pendingUpdate, "Another update already pending!");
        // Check that test does not currently fail proposed threshold
        require(
            calculateAssetBalance(thetaVaults[index], assets[index]) >= threshold,
            "test would fail proposed threshold!"
        );

        pendingVaultIndex = index;
        newThreshold = threshold;
        updateCommittedTime = block.timestamp;
        pendingUpdate = true;
        emit AnteRibbonTestPendingUpdate(thetaVaults[index], thresholds[index], threshold);
    }

    /// @notice Update test failure threshold after waiting period has passed.
    ///         Can be called by anyone, just costs gas
    function executeUpdateFailureThreshold() public {
        require(pendingUpdate, "No update pending!");
        require(
            block.timestamp > updateCommittedTime + UPDATE_FAILURE_WAITING_PERIOD,
            "Need to wait 2 days to adjust failure threshold!"
        );
        emit AnteRibbonTestUpdated(thetaVaults[pendingVaultIndex], thresholds[pendingVaultIndex], newThreshold);
        thresholds[pendingVaultIndex] = newThreshold;

        lastUpdated = block.timestamp;
        pendingUpdate = false;
    }
}
