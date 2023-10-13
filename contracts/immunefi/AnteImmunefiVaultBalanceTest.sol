// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Immunefi Vault Balance Test
/// @notice Ante Test to check if Immunefi's vault maintains a USDC balance greater than the value of 
///          their smallest bounty (USD $1000).
contract AnteImmunefiVaultBalanceTest is AnteTest("Immunefi Vault USDC Balance greater than 1 thousand USD") {
    
    address public constant vaultAddr = 0xf4a8714f6ca5Bf232F10b308C693448738be0661;
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IERC20Metadata public USDC = IERC20Metadata(usdcAddr);
    AggregatorV3Interface internal priceFeed;

    uint256 public immutable thresholdBalance;

    constructor() {
        protocolName = "Immunefi";
        testedContracts = [vaultAddr];
        thresholdBalance = 1000;
        priceFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    }

    /// @return thresholdBalance adjusted with decimals (6 decimals)
    function getThresholdBalance() public view returns (uint256) {
        return thresholdBalance * 10**USDC.decimals();
    }

    /// @return USDC balance in Immunefi Vault (6 decimals)
    function getVaultBalance() public view returns (uint256) {
        return USDC.balanceOf(vaultAddr);
    }

    /// @return price of USD in USDC (8 decimals)
    function getUsdcPrice()  public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    /// @return USD value of USDC in the Immunefi vault (0 decimals)
    function getVaultBalanceInUSD() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        if (price < 0) {
            return 0;
        }
        else return getVaultBalance() * 10**2 / uint256(price);
    }

    /// @return true if the value of USDC in the Immunefi vault > USD $1000
    function checkTestPasses() public view override returns (bool) {
        return getVaultBalanceInUSD() > thresholdBalance;
    }
}
