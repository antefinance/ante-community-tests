// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IOlympusAuthority.sol";

import "hardhat/console.sol";

/// @title OlympusDAO OHMv2 supply fully backed by Olympus treasury
/// @notice Ante Test to check Olympus treasury balance exceeds the OHMv2 token supply
/// @dev OHM Backing formula: https://docs.olympusdao.finance/main/references/equations#backing-per-ohm
contract AnteOHMv2BackingTest is AnteTest("Olympus OHMv2 fully backed by treasury reserves") {
    IERC20 public ohm;
    IOlympusAuthority public authority;

    /// @param _authorityAddress Olympus Treasury contract address (0x1c21f8ea7e39e2ba00bc12d2968d63f4acb38b7a on mainnet)
    /// @param _ohmAddress Olympus OHMv2 Token contract address (0x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5 on  mainnet)
    constructor(address _authorityAddress, address _ohmAddress) {
        ohm = IERC20(_ohmAddress);
        authority = IOlympusAuthority(_authorityAddress);

        protocolName = "OlympusDAO";
        // treasury reserves being tested but treasury address is read through authority
        // and could change in future
        testedContracts = [_ohmAddress, _authorityAddress, authority.vault()];
    }

    /// @notice convenience method for getting treasury interface from authority
    /// @return current treasury address initialized as ITreasury interface
    function olympusVault() public view returns (ITreasury) {
        return ITreasury(authority.vault());
    }

    /// @notice test to check OHMv2 token supply against total treasury reserves
    /// @return true Olympus treasury reserves exceed OHMv2 supply
    function checkTestPasses() external view override returns (bool) {
        uint256 reserves;
        ITreasury treasury = olympusVault();

        bool hasMore = true;
        uint256 i;
        while (hasMore) {
            try treasury.registry(ITreasury.STATUS.RESERVETOKEN, i++) returns (address reserveToken) {
                console.log("reserveToken %s", reserveToken);
                if (treasury.permissions(ITreasury.STATUS.RESERVETOKEN, reserveToken)) {
                    reserves += treasury.tokenValue(reserveToken, IERC20(reserveToken).balanceOf(address(treasury)));
                }
            } catch {
                hasMore = false;
            }
        }

        i = 0;
        hasMore = true;

        while (hasMore) {
            try treasury.registry(ITreasury.STATUS.LIQUIDITYTOKEN, i++) returns (address liquidityToken) {
                if (treasury.permissions(ITreasury.STATUS.LIQUIDITYTOKEN, liquidityToken)) {
                    reserves += treasury.tokenValue(
                        liquidityToken,
                        IERC20(liquidityToken).balanceOf(address(treasury))
                    );
                }
            } catch {
                hasMore = false;
            }
        }

        console.log("ohm supply %s", ohm.totalSupply());
        console.log("reserves %s", reserves);

        return reserves >= ohm.totalSupply();
    }
}
