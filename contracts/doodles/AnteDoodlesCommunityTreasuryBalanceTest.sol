// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks WETH + ETH balance in Doodles Community Treasury remains >=  30
/// @author Put your ETH address here
/// @notice Ante Test to check
contract AnteDoodlesCommunityTreasuryBalanceTest is
    AnteTest("Doodles Community Treasury WETH + ETH balance remains >= 30")
{
    // https://etherscan.io/address/0xdcd382be6cc4f1971c667ffda85c7a287605afe4
    address public constant HOLDER_ADDRESS = 0xDcd382bE6cC4f1971C667ffDa85C7a287605afe4;

    // https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    IERC20Metadata public constant TOKEN = IERC20Metadata(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Will be set to desired token balance threshold
    uint256 public immutable thresholdBalance;

    constructor() {
        // TODO replace (1000 * 1000) with desired threshold
        thresholdBalance = (30) * (10**TOKEN.decimals());

        // TODO replace "Protocol" with target protocol/wallet/etc.
        protocolName = "doodles";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if WETH + ETH balance in Doodles Community Treasury is >= 30
    /// @return true if WETH + ETH balance in Doodles Community Treasury is >= 30
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) + HOLDER_ADDRESS.balance >= thresholdBalance);
    }
}
