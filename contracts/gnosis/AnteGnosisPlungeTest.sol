pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// @title Gnosis Plunge Test
contract GnosisTVLPlungeTest is AnteTest("Make sure the TVL is at least 15% of the original TVL") {

    ERC20 private constant USDT = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 private constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 private constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 private constant UST = ERC20(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);
    ERC20 private constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); 

    ERC20 private constant GNOSIS_CONTRACT = ERC20(0x6F400810b62df8E13fded51bE75fF5393eaa841F);

    uint256 private immutable oldTVL;

    constructor() {
        testedContracts = [0x6F400810b62df8E13fded51bE75fF5393eaa841F];
        protocolName = "Gnosis";

        oldTVL = getBalances();
    }

    // @return the current tvl
    function getBalances() public view returns(uint256) {
        uint256 usdtBalance = USDT.balanceOf(0x6F400810b62df8E13fded51bE75fF5393eaa841F);
        uint256 usdcBalance = USDC.balanceOf(0x6F400810b62df8E13fded51bE75fF5393eaa841F);
        uint256 daiBalance = DAI.balanceOf(0x6F400810b62df8E13fded51bE75fF5393eaa841F);
        uint256 ustBalance = UST.balanceOf(0x6F400810b62df8E13fded51bE75fF5393eaa841F);
        uint256 wethBalance = WETH.balanceOf(0x6F400810b62df8E13fded51bE75fF5393eaa841F);

        // USDC and USDT use 6 decimals. Everything else uses 18. Need to convert it for equal weight.
        usdtBalance = usdtBalance / 10 ** 12;
        usdcBalance = usdcBalance / 10 ** 12;

        // y should always be larger than x
        return (usdtBalance + usdcBalance + daiBalance + ustBalance + wethBalance);
    }

    // @return if the new tvl is greater than 15% of the old tvl
    function checkTestPasses() public view override returns (bool) {
        return (getBalances() * 100 / oldTVL > 15);
    }
}
