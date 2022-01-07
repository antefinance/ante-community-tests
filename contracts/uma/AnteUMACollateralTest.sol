// SPDX-License-Identifier: MIT

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../AnteTest.sol";


/// @title Interface for an UMA LongShortPair
interface ILongShortPair {

  /// @return Amount of collateral a pair of tokens is always redeemable for.
  function collateralPerPair() external view returns (uint256);

  /// @return The ERC20 token that is used as collateral
  function collateralToken() external view returns (IERC20);

  /// @return The ERC20 token used as the long for the LongShortPair.
  function longToken() external view returns (IERC20);

  /// @return The ERC20 token used as the short for the LongShortPair.
  function shortToken() external view returns (IERC20);
}


/// @title Amount of collateral token locked equals long/short tokens minted times collateral
/// @notice Connects to deployed UMA LSP contracts to check their functionality
contract AnteUMACollateralTest is AnteTest(
  "Collateral token locked matches Long and Short tokens minted times collateral"
) {
  using SafeMath for uint256;

  /// @param umaLspAddr array of UMA LSP addresses to check against
  constructor(address[] memory umaLspAddr) {
    protocolName = "UMA";
    testedContracts = umaLspAddr;
  }

  /// @return true if all contracts have balanced minted tokens times collateral to locked collateral
  function checkTestPasses() public view override returns (bool) {
    for (uint256 i = 0; i < testedContracts.length; i++) {
      ILongShortPair umaLsp = ILongShortPair(testedContracts[i]);
      uint256 collateral = umaLsp.collateralPerPair();
      uint256 collateralLocked = umaLsp.collateralToken().balanceOf(testedContracts[i]);
      uint256 longTokensMinted = umaLsp.longToken().totalSupply();
      uint256 shortTokensMinted = umaLsp.shortToken().totalSupply();
      if (longTokensMinted != shortTokensMinted) {
        return false;
      }
      if (collateral.mul(longTokensMinted).div(1e18) != collateralLocked) {
        return false;
      }
    }
    return true;
  }
}