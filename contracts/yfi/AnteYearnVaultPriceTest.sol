// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../AnteTest.sol";

interface YFIVault {
    function pricePerShare() external view returns (uint256);
}

/// @title YFI Vault Price Per Share Test
/// @notice Test to ensure YFI vaults are increasing the price per share
contract AnteYearnVaultPriceTest is AnteTest("YFI Vaults price per share increasing") {
    
    uint256 private blockTimeout;
    uint256 private lastUpdatedBlock;
    uint256 public originalPricePerShare;

    address public immutable vault;
    YFIVault public immutable yYFIVault;

    constructor (address _vault, uint256 _blockTimeout) {
        protocolName = "YFI";
        testedContracts = [_vault];

        vault = _vault;
        yYFIVault = YFIVault(vault);
        originalPricePerShare = yYFIVault.pricePerShare();

        lastUpdatedBlock = block.number;
        blockTimeout = _blockTimeout;
    }

    /// @notice Update the price per share
    function updatePricePerShare() public {
        require(block.number - lastUpdatedBlock > blockTimeout, "Can only update once per preset blocks");
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
