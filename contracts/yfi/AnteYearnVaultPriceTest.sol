// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../AnteTest.sol";

interface YFIVault {
    function pricePerShare() external view returns (uint256);
}

/// @title YFI Vault Price Per Share Test
/// @notice Test to ensure YFI vaults are increasing the price per share
contract AnteYearnVaultPriceTest is AnteTest("YFI Vaults price per share increasing") {
    
    address public immutable vault;
    uint256 public immutable originalPricePerShare;
    YFIVault public immutable yYFIVault;

    constructor (address _vault) {
        protocolName = "YFI";
        testedContracts = [_vault];

        vault = _vault;
        yYFIVault = YFIVault(vault);
        originalPricePerShare = yYFIVault.pricePerShare();
    }

    /// @return current price per share
    function getNewPricePerShare() public view returns (uint256) {
        return yYFIVault.pricePerShare();
    }

    /// @return true if the price per share is increasing or the same
    function checkTestPasses() public view override returns (bool) {
        
        return getNewPricePerShare() >= originalPricePerShare;
    }
}
