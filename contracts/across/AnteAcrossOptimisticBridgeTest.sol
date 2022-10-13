// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

/// @title AcrossBridgeTest
/// @notice Ante Test to check if Across Optimistic "rugs" 70% of its value (as of test deployment)

contract AnteAcrossOptimisticBridgeTest is AnteTest("Across Bridge does not RUG its 70 % of its value") {
    // Contracts
    // https://docs.across.to/v2/developers/contract-addresses/mainnet-chain-id-1

    // HubPool Address: The  main contract Holds Assets
    address public constant hubPoolAddr = 0xc186fA914353c44b2E33eBE05f21846F1048bEda;

    // Pool Assetss

    // Lets 3 Major Assets:  WETH USDC DAI
    // WETH:  https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    address public constant wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // Dai:  https://etherscan.io/address/0x6B175474E89094C44Da98b954EedeAC495271d0F
    address public constant daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // USDC: https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint256 public constant THRESHOLD = 30;

    IERC20 private constant WETH = IERC20(wethAddr);
    IERC20 private constant DAI = IERC20(daiAddr);
    IERC20 private constant USDC = IERC20(usdcAddr);

    uint256 public immutable wethThreshold;
    uint256 public immutable daiThreshold;
    uint256 public immutable usdcThreshold;

    constructor() {
        protocolName = "Across";
        testedContracts = [hubPoolAddr];

        wethThreshold = (WETH.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
        daiThreshold = (DAI.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
        usdcThreshold = (USDC.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
    }

    /// @notice test to check value of top 3 tokens on Across Bridge
    /// @return true if bridge has more than 30% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        return
            wethThreshold < WETH.balanceOf(hubPoolAddr) &&
            daiThreshold < DAI.balanceOf(hubPoolAddr) &&
            usdcThreshold < USDC.balanceOf(hubPoolAddr);
    }
}
