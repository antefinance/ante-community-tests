pragma solidity ^0.8.0;

import "../AnteTest.sol";

/// @title Curve stETH Doesn't Rug
contract AnteSTETHCurveRugTest is AnteTest("Curve stETH Keeps 99% of it's ETH.") {
    // https://etherscan.io/address/0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
    address public stETHCurveSwap = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;

    // 2022-04-05: stETH Curve Contract has 800k ETH, so -99% is ~8k ETH
    uint256 public constant RUG_THRESHOLD = 8 * 1000 * 1e18;

    constructor() {
        protocolName = "Curve";
        testedContracts = [stETHCurveSwap];
    }

    /// @notice test to check balance of stETH curve pool
    /// @return true if stETH Curve pool  has over 4000 ETH
    function checkTestPasses() external view override returns (bool) {
        return stETHCurveSwap.balance >= RUG_THRESHOLD;
    }
}
