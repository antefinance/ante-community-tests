// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.7.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
import "../AnteTest.sol";
import "hardhat/console.sol";
import "./interfaces/Treasury.sol";

/// @title OlympusDAO OHM supply fully backed by Olympus treasury
/// @notice Ante Test to check Olympus treasury balance exceeds the OHM token supply
/// @dev OHM Backing formula: https://docs.olympusdao.finance/main/references/equations#backing-per-ohm
contract AnteOHMBackingTest is AnteTest("Olympus OHM fully backed by treasury reserves") {
  using SafeMath for uint256;

  IERC20 public OHMToken;
  OlympusTreasury public olympusTreasury;

  /// @param _olympusTreasuryAddr Olympus Treasury contract address (0x31F8Cc382c9898b273eff4e0b7626a6987C846E8 on mainnet)
  /// @param _ohmTokenAddr Olympus OHM Token contract address (0x383518188c0c6d7730d91b2c03a03c837814a899 on  mainnet)
  constructor(address _olympusTreasuryAddr, address _ohmTokenAddr) {
      OHMToken = IERC20(_ohmTokenAddr);

      olympusTreasury = OlympusTreasury(_olympusTreasuryAddr);
      protocolName = "OlympusDAO";
      testedContracts = [_ohmTokenAddr, _olympusTreasuryAddr];
  }

  /// @notice test to check OHM token supply against total treasury reserves
  /// @return true Olympus treasury reserves exceed OHM supply
  function checkTestPasses() external view override returns (bool) {
    uint256 reserves;
    bool hasMore = true;
    uint i;

    while(hasMore) {
      try olympusTreasury.reserveTokens(i++) returns (address reserveToken) {
        reserves = reserves.add(
          olympusTreasury.valueOf(reserveToken, IERC20(reserveToken).balanceOf(address(olympusTreasury)))
        );
      } catch {
        hasMore = false;
      }
    }
    i = 0;
    hasMore = true;
    while(hasMore) {
      try olympusTreasury.liquidityTokens(i++) returns (address liquidityToken) {
        reserves = reserves.add(
          olympusTreasury.valueOf(liquidityToken, IERC20(liquidityToken).balanceOf(address(olympusTreasury)))
        );
      } catch {
        hasMore = false;
      }
    }
    return reserves >= OHMToken.totalSupply();
  }
}
