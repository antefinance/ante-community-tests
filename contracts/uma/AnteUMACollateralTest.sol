// SPDX-License-Identifier: MIT

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../AnteTest.sol";
//import "./LongShortPair.sol";
import "./interfaces/ILongShortPair.sol";


/// @title Amount of collateral token locked equals long/short tokens minted times collateral
/// @notice Connects to deployed UMA LSP contracts to check their functionality
contract AnteUMACollateralTest is AnteTest(
  "Collateral token locked matches Long and Short tokens minted times collateral"
) {

  /// @param umaLspAddr array of UMA LSP addresses to check against
  constructor(address[] memory umaLspAddr) {
    protocolName = "UMA";
    testedContracts = umaLspAddr;
  }

  /// @return true if all contracts have balanced minted tokens times collateral to locked collateral
  function checkTestPasses() public view override returns (bool) {
    for (uint256 i = 0; i < testedContracts.length; i++) {
      LongShortPair umaLsp = ILongShortPair(testedContracts[i]);
      uint256 collateral = umaLsp.collateralPerPair;
      uint256 collateralLocked = IERC20(umaLsp.collateralToken).balanceOf(testedContracts[i]);
      uint256 longTokensMinted = IERC20(umaLsp.longToken).totalSupply();
      uint256 shortTokensMinted = IERC20(umaLsp.shortToken).totalSupply();
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