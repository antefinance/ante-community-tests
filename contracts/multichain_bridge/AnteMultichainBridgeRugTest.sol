// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "hardhat/console.sol";
import "../interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "../AnteTest.sol";

// Ante Test that the top 5 assets do not get rugged. (lose 90% of value.)
contract AnteMultichainBridgeRugTest is AnteTest("Top 5 assets do not lose 90% value.") {
    // Externally Owned Account - https://etherscan.io/address/0x13B432914A996b0A48695dF9B2d701edA45FF264
    address public constant eoaAnyswapBSCBridgeAddr = 0x13B432914A996b0A48695dF9B2d701edA45FF264;

    // Used https://anyswap.net/tokens sorted by TVL to determine the top 5 assets.

    //Anyswap - https://etherscan.io/address/0xf99d58e463A2E07e5692127302C20A191861b4D6
    address public constant anyswapAddr = 0xf99d58e463A2E07e5692127302C20A191861b4D6;

    //Fanthom - https://etherscan.io/address/0x4e15361fd6b4bb609fa63c81a2be19d873717870
    address public constant ftmAddr = 0x4E15361FD6b4BB609Fa63C81A2be19d873717870;

    //USDC - https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    //TetherUSD - https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address public constant tetherAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    //DaiStablecoin - https://etherscan.io/address/0x6B175474E89094C44Da98b954EedeAC495271d0F
    address public constant daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IERC20 public anyswapToken;
    IERC20 public ftmToken;
    IERC20 public usdcToken;
    IERC20 public tetherToken;
    IERC20 public daiToken;
    uint256 public immutable anyswapBalanceAtDeploy;
    uint256 public immutable ftmBalanceAtDeploy;
    uint256 public immutable usdcBalanceAtDeploy;
    uint256 public immutable tehterBalanceAtDeploy;
    uint256 public immutable daiBalanceAtDeploy;

    constructor() {
        protocolName = "Anyswap: BSC Bridge";
        testedContracts = [eoaAnyswapBSCBridgeAddr];

        anyswapToken = IERC20(anyswapAddr);
        ftmToken = IERC20(ftmAddr);
        usdcToken = IERC20(usdcAddr);
        tetherToken = IERC20(tetherAddr);
        daiToken = IERC20(daiAddr);

        // Snapshot of top 5 tokens.
        anyswapBalanceAtDeploy = anyswapToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        ftmBalanceAtDeploy = ftmToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        usdcBalanceAtDeploy = usdcToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        tehterBalanceAtDeploy = tetherToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        daiBalanceAtDeploy = daiToken.balanceOf(eoaAnyswapBSCBridgeAddr);
    }

    function checkTestPasses() public view override returns (bool) {
        return
            anyswapBalanceAtDeploy * 90 <= anyswapToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 100 &&
            ftmBalanceAtDeploy * 90 <= ftmToken.balanceOf(eoaAnyswapBSCBridgeAddr)* 100 &&
            usdcBalanceAtDeploy * 90 <= usdcToken.balanceOf(eoaAnyswapBSCBridgeAddr)* 100 &&
            tehterBalanceAtDeploy * 90 <= tetherToken.balanceOf(eoaAnyswapBSCBridgeAddr)* 100 &&
            daiBalanceAtDeploy * 90 <= daiToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 100;
    }
}
