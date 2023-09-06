// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


/// @title Checks stETH and ETH in curve pool remains above 10% from deployment
/// @author 0xa0e7Fb16cdE37Ebf2ceD6C89fbAe8780B8497e12
contract AnteCurvestEthEthPoolTest is AnteTest("Curve stETH/ETH pool balances remain >= 10% of deployment") {
    // https://etherscan.io/address/0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
    address public constant POOL_ADDRESS = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;

    // https://etherscan.io/address/0xae7ab96520de3a18e5e111b5eaab095312d7fe84
    IERC20Metadata public constant STETH_TOKEN = IERC20Metadata(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    uint256 public immutable ethThresholdBalance;
    uint256 public immutable stEthThresholdBalance;

    constructor() {
        ethThresholdBalance = POOL_ADDRESS.balance;
        stEthThresholdBalance = STETH_TOKEN.balanceOf(POOL_ADDRESS);

        protocolName = "Lido";

        testedContracts = [address(STETH_TOKEN), POOL_ADDRESS];
    }

    /// @notice test to check if both ETH and stETH remain above 10% since deployment
    /// @return true if ETH and stETH are above 10% of deployment amounts
    function checkTestPasses() public view override returns (bool) {
        return (
            POOL_ADDRESS.balance >= ethThresholdBalance / 10 &&
            STETH_TOKEN.balanceOf(POOL_ADDRESS) >= stEthThresholdBalance / 10
        );
    }
}
