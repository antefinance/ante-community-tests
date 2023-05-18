// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks $COMP balance in Compound: Reservoir remains >= 100,000
/// @author 0x030EfED5792ea91daDa92aB518Ed2b616Ef094ba
/// @notice Ante Test to check

contract AnteCompoundTokenBalanceAbove100KTest is AnteTest("Compound: Reservoir COMP balance remains >= 100,000") {

    // https://etherscan.io/address/0x2775b1c75658Be0F640272CCb8c72ac986009e38
    address public constant HOLDER_ADDRESS = 0x2775b1c75658Be0F640272CCb8c72ac986009e38;

    // https://etherscan.io/address/0xc00e94Cb662C3520282E6f5717214004A7f26888
    IERC20Metadata public constant TOKEN = IERC20Metadata(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    uint256 public immutable thresholdBalance;

    constructor() {

        thresholdBalance = (100 * 1000) * (10**TOKEN.decimals());


        protocolName = "Compound";

        testedContracts = [address(TOKEN), HOLDER_ADDRESS];
    }

    /// @notice test to check if 0xc00e94Cb662C3520282E6f5717214004A7f26888 balance in 0x2775b1c75658Be0F640272CCb8c72ac986009e38 is >= 100,000
    /// @return true if 0xc00e94Cb662C3520282E6f5717214004A7f26888 balance in 0x2775b1c75658Be0F640272CCb8c72ac986009e38 is >= 100,000
    function checkTestPasses() public view override returns (bool) {
        return (TOKEN.balanceOf(HOLDER_ADDRESS) >= thresholdBalance);
    }
}
