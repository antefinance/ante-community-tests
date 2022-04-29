// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../AnteTest.sol";
import "../interfaces/IERC20.sol";

/// @title YFI Supply Test
/// @notice Test to ensure YFI doesn't get hit with a infinite mint exploit
contract AnteYFISupplyTest is AnteTest("YFI doesn't inflate 10x over 2 months") {

    uint256 private lastCheckedYFISupply;
    uint256 private lastCheckedEpoch;
    uint256 private constant TWO_MONTHS_IN_SECONDS = 60 * 60 * 24 * 60;
    uint256 private constant ONE_MONTHS_IN_SECONDS = 60 * 60 * 24 * 30;
    
    address private constant YFI_ADDRESS = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    IERC20 private constant YFI_CONTRACT = IERC20(YFI_ADDRESS);
    
    constructor () {
        protocolName = "YFI";
        testedContracts = [YFI_ADDRESS];

        lastCheckedYFISupply = YFI_CONTRACT.totalSupply();
        lastCheckedEpoch = block.timestamp;
    }

    /// @notice Update's the last checked YFI supply and timestamp. 
    /// @dev Can only be called once every month to prevent spam reloading.
    function updateSupply() external {
        require(block.timestamp > lastCheckedEpoch + ONE_MONTHS_IN_SECONDS, "Can only be updated once per month");
        lastCheckedYFISupply = YFI_CONTRACT.totalSupply();
        lastCheckedEpoch = block.timestamp;
    }

    /// @return last time the YFI supply was updated
    function getLastUpdate() external view returns (uint256) {
        return lastCheckedEpoch;
    }
    
    /// @notice Check if YFI supply is inflated over 1000% over 2 months
    /// @dev Please note that if the 2 months has passed, the test will automatically pass
    /// @dev To reset the timer, call the updateSupply() function
    function checkTestPasses() public view override returns (bool) {
        uint256 currentYFISupply = YFI_CONTRACT.totalSupply();
        uint256 currentEpoch = block.timestamp;

        if (currentEpoch - lastCheckedEpoch > TWO_MONTHS_IN_SECONDS) {
            return true;
        }

        uint256 inflation = currentYFISupply / lastCheckedYFISupply;

        if (inflation > 10) {
            return false;
        }
        
        return true;
    }
}
