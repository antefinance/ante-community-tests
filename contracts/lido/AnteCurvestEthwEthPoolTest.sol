// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


/// @title Checks stETH and wETH in curve concentrated pool remains above 10% from deployment
/// @author 0xa0e7Fb16cdE37Ebf2ceD6C89fbAe8780B8497e12
contract AnteCurvestEthEthPoolTest is AnteTest("Curve stETH/ETH pool balances remain >= 10% of deployment") {
    // https://etherscan.io/address/0x828b154032950C8ff7CF8085D841723Db2696056
    address public constant POOL_ADDRESS = 0x828b154032950C8ff7CF8085D841723Db2696056;

    // https://etherscan.io/address/0xae7ab96520de3a18e5e111b5eaab095312d7fe84
    IERC20Metadata public constant STETH_TOKEN = IERC20Metadata(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    // https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    IERC20Metadata public constant WETH_TOKEN = IERC20Metadata(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint256 public immutable wEthThresholdBalance;
    uint256 public immutable stEthThresholdBalance;

    constructor() {
        wEthThresholdBalance = WETH_TOKEN.balanceOf(POOL_ADDRESS);
        stEthThresholdBalance = STETH_TOKEN.balanceOf(POOL_ADDRESS);

        protocolName = "Lido";

        testedContracts = [address(STETH_TOKEN), POOL_ADDRESS];
    }

    /// @notice test to check if both wETH and stETH remain above 10% since deployment
    /// @return true if wETH and stETH are above 10% of deployment amounts
    function checkTestPasses() public view override returns (bool) {
        return (
            WETH_TOKEN.balanceOf(POOL_ADDRESS) >= wEthThresholdBalance / 10 &&
            STETH_TOKEN.balanceOf(POOL_ADDRESS) >= stEthThresholdBalance / 10
        );
    }
}
