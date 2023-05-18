pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice A Beefy yield farming vault
interface IBeefyVault is IERC20 {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getPricePerFullShare() external view returns (uint256);
}