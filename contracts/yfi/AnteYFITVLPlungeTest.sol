// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

/// @title YFI TVL Test
/// @notice Test to ensure YFI vaults don't lose more than 90% of it's TVL
contract AnteYFITVLPlungeTest is AnteTest("YFI vaults don't lose 90% of it's TVL") {
    address private constant YFI_ADDRESS = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address private constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WBTC_ADDRESS = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 private constant YFI_CONTRACT = IERC20(YFI_ADDRESS);
    IERC20 private constant WETH_CONTRACT = IERC20(WETH_ADDRESS);
    IERC20 private constant USDC_CONTRACT = IERC20(USDC_ADDRESS);
    IERC20 private constant DAI_CONTRACT = IERC20(DAI_ADDRESS);
    IERC20 private constant WBTC_CONTRACT = IERC20(WBTC_ADDRESS);
    IERC20 private constant USDT_CONTRACT = IERC20(USDT_ADDRESS);

    address private constant YFI_VAULT_ADDRESS = 0xE14d13d8B3b85aF791b2AADD661cDBd5E6097Db1;
    address private constant WETH_VAULT_ADDRESS = 0xa258C4606Ca8206D8aA700cE2143D7db854D168c;
    address private constant USDC_VAULT_ADDRESS = 0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9;
    address private constant DAI_VAULT_ADDRESS = 0xdA816459F1AB5631232FE5e97a05BBBb94970c95;
    address private constant WBTC_VAULT_ADDRESS = 0xcB550A6D4C8e3517A939BC79d0c7093eb7cF56B5;
    address private constant USDT_VAULT_ADDRESS = 0x7Da96a3891Add058AdA2E826306D812C638D87a7;

    uint256 public immutable originalBalance;

    constructor() {
        protocolName = "YFI";
        testedContracts = [
            YFI_VAULT_ADDRESS,
            WETH_VAULT_ADDRESS,
            USDC_VAULT_ADDRESS,
            DAI_VAULT_ADDRESS,
            WBTC_VAULT_ADDRESS,
            USDT_VAULT_ADDRESS
        ];

        originalBalance =
            YFI_CONTRACT.balanceOf(YFI_VAULT_ADDRESS) +
            WETH_CONTRACT.balanceOf(WETH_VAULT_ADDRESS) +
            USDC_CONTRACT.balanceOf(USDC_VAULT_ADDRESS) +
            DAI_CONTRACT.balanceOf(DAI_VAULT_ADDRESS) +
            WBTC_CONTRACT.balanceOf(WBTC_VAULT_ADDRESS) +
            USDT_CONTRACT.balanceOf(USDT_VAULT_ADDRESS);
    }

    /// @return current TVL of YFI vaults
    function getBalance() public view returns (uint256) {
        return
            YFI_CONTRACT.balanceOf(YFI_VAULT_ADDRESS) +
            WETH_CONTRACT.balanceOf(WETH_VAULT_ADDRESS) +
            USDC_CONTRACT.balanceOf(USDC_VAULT_ADDRESS) +
            DAI_CONTRACT.balanceOf(DAI_VAULT_ADDRESS) +
            WBTC_CONTRACT.balanceOf(WBTC_VAULT_ADDRESS) +
            USDT_CONTRACT.balanceOf(USDT_VAULT_ADDRESS);
    }

    /// @return if YFI keeps at least 10% of it's original TVL
    function checkTestPasses() public view override returns (bool) {
        return (getBalance() * 100) / originalBalance > 10;
    }
}
