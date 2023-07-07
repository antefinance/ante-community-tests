// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks $PEPE balance in Top 5 holders is greater than 90% of holdings recorded at deployment of AnteTest
/// @author jseam.eth
/// @notice Ante Test to check if top PEPE holders are going to dump
// TODO Change AnteTokenBalanceTestTemplate to the filename of the test,
contract AntePepeDumpTest is AnteTest("Top 5 Holders don't dump > ~10% as of deployment") {
    // https://etherscan.io/address/0xdaeada3d210d2f45874724beea03c7d4bbd41674
    address[] public HOLDERS_ADDRESS;

    // set in constructor
    uint256[] public THRESHOLD_BALANCE;

    // https://etherscan.io/address/0x6982508145454Ce325dDbE47a25d4ec3d2311933
    IERC20Metadata public constant TOKEN = IERC20Metadata(0x6982508145454Ce325dDbE47a25d4ec3d2311933);

    constructor() {
        HOLDERS_ADDRESS.push(0x92FB5b4F8030103e0b11275c30965d1897ff23E5);
        HOLDERS_ADDRESS.push(0x4a2C786651229175407d3A2D405d1998bcf40614);
        HOLDERS_ADDRESS.push(0x069985cc108aC48847bCC9b3FAEe6e71aE8CCF33);
        HOLDERS_ADDRESS.push(0x25CD302E37a69D70a6Ef645dAea5A7de38c66E2a);
        HOLDERS_ADDRESS.push(0x9Cd6140c2De8AF7595629bCcA099497f0c28B2A9);


        for (uint256 i = 0; i < 5;) {
            THRESHOLD_BALANCE.push(TOKEN.balanceOf(HOLDERS_ADDRESS[i]) * 9000 / 10000);
            unchecked {
                ++i;
            }
        }

        protocolName = "PEPE Token";

        testedContracts = [address(TOKEN)];
    }

    /// @notice test to check if $PEPE balance in HOLDERS_ADDRESS is more than 90% at deployment of the AnteTest
    /// @return true if all $PEPE balance in HOLDERS_ADDRESS is more than 90% at deployment of the AnteTest
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < 5;) {
            if (!(TOKEN.balanceOf(HOLDERS_ADDRESS[i]) >= THRESHOLD_BALANCE[i])) {
                return false;
            }
            unchecked {
                ++i;
            }
        }
        return true;
    }
}
