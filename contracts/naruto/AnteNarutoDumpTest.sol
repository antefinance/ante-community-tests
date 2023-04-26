// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Checks $NARUTO balance in Top 10 holders is greater than 90% of holdings recorded at deployment of AnteTest
/// @author jseam.eth
/// @notice Ante Test to check if top NARUTO holders are going to dump
contract AnteNarutoDumpTest is AnteTest("Top 10 Holders don't dump > ~10% as of deployment") {
    // https://etherscan.io/address/0xAD8D0de33C43eEFe104A279cDB6Ae250C12e6214
    address[] public HOLDERS_ADDRESS;

    // set in constructor
    uint256[] public THRESHOLD_BALANCE;

    // https://etherscan.io/address/0xAD8D0de33C43eEFe104A279cDB6Ae250C12e6214
    IERC20Metadata public constant TOKEN = IERC20Metadata(0xAD8D0de33C43eEFe104A279cDB6Ae250C12e6214);

    constructor() {
        HOLDERS_ADDRESS.push(0x444D134981cB23649CA603E98f9424960BCcECBC);
        HOLDERS_ADDRESS.push(0xA1F79eF31BE0D019c5187718a9380440266E213e);
        HOLDERS_ADDRESS.push(0xA0E5cEf5B124B953EB8d7d5EdC8BC432E7930De0);
        HOLDERS_ADDRESS.push(0x591660bf3Ae48260bD21Aef41e7dfd795FE4406a);
        HOLDERS_ADDRESS.push(0xabbaAA15512e6ED55Bd10221f189463b3d32DdfB);
        HOLDERS_ADDRESS.push(0xF16994FfA56Cf504067Be9768b5071769A1303d6);
        HOLDERS_ADDRESS.push(0xB42209fC9A65cbaB46267dF4677308ff8675389c);
        HOLDERS_ADDRESS.push(0xe5E2f5672BbB5D8888949E403ec2aAa3f97Cb00f);
        HOLDERS_ADDRESS.push(0x6635eCB26290fc4BbA9517314d32BA8E0758aAE1);
        HOLDERS_ADDRESS.push(0xFF243e5a89F998b7675BDcCd64A067f1a9916243);



        for (uint256 i = 0; i < 10;) {
            THRESHOLD_BALANCE.push(TOKEN.balanceOf(HOLDERS_ADDRESS[i]) * 9000 / 10000);
            unchecked {
                ++i;
            }
        }

        protocolName = "NARUTO";

        testedContracts = [address(TOKEN)];
    }

    /// @notice test to check if $NARUTO balance in HOLDERS_ADDRESS is more than 90% at deployment of the AnteTest
    /// @return true if all $NARUTO balance in HOLDERS_ADDRESS is more than 90% at deployment of the AnteTest
    function checkTestPasses() public view override returns (bool) {
        for (uint256 i = 0; i < 10;) {
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
