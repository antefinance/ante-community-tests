// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";

interface IAuriOracle {
    function mainFeed(address input)
        external
        view
        returns (
            uint216,
            uint8,
            uint32
        );
}

/// @title Checks that auUSDC is pegged, checking if it's above 90 cents
/// @author delalunia
contract AnteAurigamiUSDCPegTest is AnteTest("auUSDC stays above 90 cents on the US dollar") {
    // https://aurorascan.dev/address/0x4f0d864b1ABf4B701799a0b30b57A22dFEB5917b
    address public immutable auUSDCAddr;

    IAuriOracle internal aurigamiPriceFeed;

    constructor(address _auUSDCAddr) {
        protocolName = "Aurigami";
        auUSDCAddr = _auUSDCAddr;
        testedContracts = [_auUSDCAddr];
        aurigamiPriceFeed = IAuriOracle(0xC6e5185438e1730959c1eF3551059A3feC744E90);
    }

    function checkTestPasses() public view override returns (bool) {
        (uint216 price, uint8 decimal, ) = aurigamiPriceFeed.mainFeed(auUSDCAddr);
        return (uint256(100 * 10**(uint256(decimal)) * 9) / 10 < price);
    }
}
