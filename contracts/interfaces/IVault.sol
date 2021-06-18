// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IVault {
    function pricePerShare() external view returns (uint);
}