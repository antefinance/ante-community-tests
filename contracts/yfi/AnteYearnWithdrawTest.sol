// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;
import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IYearnVault.sol";

/// @title Yearn Withdraw Test
/// @notice Tests to see if you can withdraw from a yearn deposit
contract AnteYearnWithdrawTest is AnteTest("Makes sure you can withdraw from yearn") {

    address public immutable vault;
    address public immutable token;

    InterfaceYearnVault private immutable yearnVault;
    IERC20 private immutable tokenContract;

    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant FIFTEEEN_MINUTES_IN_SECONDS = 15 * 60;

    uint256 private tokenBalance = 0;
    uint256 private yearnBalance = 0;
    uint256 private withdrawingEpoch = 0;

    /// @param _vault The address of the yearn vault contract
    /// @param _token The address of the token contract associated with the vault
    constructor(address _vault, address _token) {
        protocolName = "Yearn";
        testedContracts = [_vault];

        vault = _vault;
        token = _token;
        yearnVault = InterfaceYearnVault(vault);
        tokenContract = IERC20(token);
    }

    /// @notice Withdraws tokens from yearn vault
    /// @dev Vault must have tokens and can only be called once per day
    /// @dev token balance - will be checked to see if value is higher in the future
    /// @dev yearn balance - will be checked to see if value is not zero. If value is zero, test will return true
    /// @dev epoch - used to ensure that some time has passed
    function withdraw() external {
        require(yearnVault.balanceOf(address(this)) > 0, "ERROR: You have no tokens to withdraw");
        require(block.timestamp - withdrawingEpoch > DAY_IN_SECONDS, "ERROR: You can only withdraw once per day");
        
        tokenBalance = tokenContract.balanceOf(address(this));
        yearnBalance = yearnVault.balanceOf(address(this));
        withdrawingEpoch = block.timestamp;

        yearnVault.withdraw();
    }

    /// @dev Must call withdraw() prior to calling this function. Or else test will always be true.
    /// @dev Must wait for 15 minutes after calling withdraw()
    /// @return if tokens have been withdrawn
    function checkTestPasses() public view override returns (bool) {
        // If yearn balance is zero, that means that either withdraw() was never called or 
        // when it was called, the contract didn't own anything in the vault.
        if(yearnBalance == 0) {
            return true;
        }

        // It may take some time to process transactions from the yearn vault back to the stablecoin contract
        if(block.timestamp - withdrawingEpoch < FIFTEEEN_MINUTES_IN_SECONDS) {
            return true;
        }

        return(tokenContract.balanceOf(address(this)) > tokenBalance);
    }
}
