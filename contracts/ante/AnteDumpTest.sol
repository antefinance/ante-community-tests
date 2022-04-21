// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";

struct WalletTest {
    address wallet;
    address token;
    uint256 amount;
    uint256 timeRegistered;
    uint256 timeValid;
    uint256 expiry;
}

/// @title  AnteDumpTest
/// @notice Ensures a wallet doens't dump x amount of tokens over y time
contract AnteDumpTest is AnteTest("Ensure a set of wallets doesn't dump their associated tokens") {
    
    WalletTest[] private walletTests;
    uint8 public immutable thresholdPercent;

    address private admin;
    address public immutable owner;

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == owner, "ANTE: Must be an admin or owner");
        _;
    }

    /// @notice Initializes the test
    /// @param _tokenAddress A list of adddresses for tokens
    /// @param _monitorWallet a list of wallets to monitor
    /// @param _thresholdPercent the percentage of tokens that must be owned by a wallet
    /// @param _timeValid the time that a wallet condition is valid
    /// @dev When passing in a list, each wallet address will correspond to the token at the same index
    /// @dev Eg [USDC, DAI] | [WALLET1, WALLET2] - WALLET1 will own USDC and WALLET2 will own DAI
    constructor(address[] memory  _tokenAddress, address[] memory _monitorWallet, uint8 _thresholdPercent, uint256 _timeValid, address _admin) {

        protocolName = "Ante";
        testedContracts = _tokenAddress;

        thresholdPercent = _thresholdPercent;

        admin = _admin;
        owner = msg.sender;

        for(uint256 i = 0; i < _monitorWallet.length; i++) {
            IERC20 token = IERC20(_tokenAddress[i]);

            WalletTest memory walletTest;

            walletTest.wallet = _monitorWallet[i];
            walletTest.token = _tokenAddress[i];
            walletTest.amount = token.balanceOf(_monitorWallet[i]);
            walletTest.timeRegistered = block.timestamp;
            walletTest.timeValid = _timeValid;
            walletTest.expiry = block.timestamp + _timeValid;

            walletTests.push(walletTest);
        }
    }

    function changeAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    /// @notice adds a wallet to the list of wallets to monitor
    /// @param _wallet the wallet to add
    /// @param _token the token address to monitor for said wallet
    /// @param _timeValid the time that a wallet condition is valid
    function addWallet(address _wallet, address _token, uint256 _timeValid) public onlyAdmin{
        IERC20 token = IERC20(_token);

        WalletTest memory walletTest;

        walletTest.wallet = _wallet;
        walletTest.token = _token;
        walletTest.amount = token.balanceOf(_wallet);
        walletTest.timeRegistered = block.timestamp;
        walletTest.timeValid = _timeValid;
        walletTest.expiry = block.timestamp + _timeValid;


        walletTests.push(walletTest);
    }

    /// @return all stored wallets and their respective information
    function getWallets() public view returns (WalletTest[] memory) {
        return walletTests;
    }

    /// @param timeRegistered the time that a wallet was registered
    /// @param timeValid the time that a wallet condition is valid
    /// @param timeStamp the current block timestamp
    /// @return allowedPErcent the percent threshold adjusted for time
    function getAllowedPercentThreshold(uint256 timeRegistered, uint256 timeValid, uint256 timeStamp) public view returns (uint256) {
        uint256 timeSinceRegistered = timeStamp - timeRegistered;
        uint256 timeRemaining = timeValid - timeSinceRegistered;

        uint256 allowedPercent = timeRemaining * thresholdPercent / timeValid;

        return allowedPercent;
    }

    /// @return if all wallet conditions are still valid
    function checkTestPasses() public view override returns (bool) {
        uint256 currentTime = block.timestamp;

        for(uint256 i = 0; i < walletTests.length; i++) {
            if(currentTime > walletTests[i].expiry) {
                continue;
            }
            IERC20 token = IERC20(walletTests[i].token);

            uint256 oldBalance = walletTests[i].amount;
            uint256 newBalance = token.balanceOf(walletTests[i].wallet);

            uint256 timeAdjustedPercent = getAllowedPercentThreshold(walletTests[i].timeRegistered, walletTests[i].timeValid, currentTime);

            if(newBalance < oldBalance * timeAdjustedPercent / 100) {
                return false;
            }
        }

        return true;
    }
}
