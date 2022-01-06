pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILongShortPair {

  //uint256 public collateralPerPair; // Amount of collateral a pair of tokens is always redeemable for.
  function collateralPerPair() external view returns (uint256);

  //IERC20 public collateralToken;
  function collateralToken() external view returns (IERC20);
  //ExpandedIERC20 public longToken;
  function longToken() external view returns (IERC20);
  //ExpandedIERC20 public shortToken;
  function shortToken() external view returns (IERC20);
}