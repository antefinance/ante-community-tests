// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FixedPointMathLib.sol";
import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "./IActivePool.sol";
import "./IYetiController.sol";

/// @title AnteYetiFinanceSupplyTest
/// @notice Ensure that the dollar value of the Yeti Finance Active pool exceeds 1.1x the total supply of YUSD
contract AnteYetiFinanceSupplyTest is AnteTest("Ensure total supply of YUSD doesn't exceed Active Pool backing") {
    using FixedPointMathLib for uint256;

    // https://docs.yeti.finance/other/contract-addresses
    address private yusd = 0x111111111111ed1D73f860F57b2798b683f2d325;
    address private activePool = 0xAAAaaAaaAaDd4AA719f0CF8889298D13dC819A15;
    address private yetiController = 0xcCCCcCccCCCc053fD8D1fF275Da4183c2954dBe3;

    IERC20 private YUSD = IERC20(yusd);
    IActivePool private ActivePool = IActivePool(activePool);
    IYetiController private YetiController = IYetiController(yetiController);

    constructor() {
        protocolName = "Yeti Finance";
        testedContracts = [activePool, yusd];
    }

    /// @return true if the TVL is > totalSupply * 1.1
    function checkTestPasses() public view override returns (bool) {
        uint256 balanceInUsd = getActivePoolTvlInUsd();
        uint256 totalSupply = YUSD.totalSupply();
        return balanceInUsd * 10 > totalSupply * 11;
    }

    function getActivePoolTvlInUsd() public view returns (uint256) {
        (address[] memory collateral, uint256[] memory amounts) = ActivePool.getAllCollateral();
        uint256 tvlInUsd = 0; // in WAD
        for (uint256 i; i < collateral.length; ++i) {
            uint256 amount = amounts[i];
            uint256 priceInUsd = YetiController.getPrice(collateral[i]);
            tvlInUsd += amount.mulWadDown(priceInUsd);
        }
        return tvlInUsd;
    }
}
