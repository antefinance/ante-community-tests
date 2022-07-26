// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

// There is another interface called IYearnVault. Using a different name to avoid hardhat throwing errors.
interface InterfaceYearnVault {
    function withdraw() external;

    function deposit() external;

    function balanceOf(address account) external view returns (uint256);
    // function deposit(uint256 amount, address receipient) external;
}
