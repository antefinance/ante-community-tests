// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AllNetworksAcrossBridgeTest
/// @notice Ante Test to check if Across Optimistic "rugs" 70% of its top 3 tokens (as of test deployment)

contract AllNetworksAnteAcrossOptimisticBridgeTest is AnteTest("Across Bridge does not rug 70% of its top 3 tokens") {
    // Contracts
    // Pool Address: The main contract that holds assets
    address public poolAddress;

    // Pool Assetss
    IERC20[] public poolAssets;

    uint256 public constant THRESHOLD = 30;

    mapping(address=>uint256) public thresholds;
    
    constructor(address _poolAddress, address[] memory _poolAssets) {
        protocolName = "Across";
        poolAddress = _poolAddress;
        testedContracts.push(_poolAddress);

        for(uint256 i = 0; i < _poolAssets.length; i++) {
            poolAssets.push(IERC20(_poolAssets[i]));
            thresholds[_poolAssets[i]] = (poolAssets[i].balanceOf(_poolAddress) * THRESHOLD) / 100;
        }

        
    }

    /// @notice test to check value of watched tokens on Across Bridge
    /// @return true if bridge has more than 30% of assets from when it was deployed
    function checkTestPasses() external view override returns (bool) {
        for(uint256 i = 0; i < poolAssets.length; i++) {
            if(thresholds[address(poolAssets[i])] > poolAssets[i].balanceOf(poolAddress)) {
                return false;
            }
        }
        return true;
    }
}
