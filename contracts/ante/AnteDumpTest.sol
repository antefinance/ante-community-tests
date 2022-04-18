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

contract AnteDumpTest is AnteTest("USDC is above 90 cents on the dollar") {
    WalletTest[] private walletTests;

    uint8 private immutable thresholdPercent;

    constructor(address[] memory  _tokenAddress, address[] memory _monitorWallet, uint8 _thresholdPercent, uint256 _timeValid) {
        protocolName = "Ante";
        testedContracts = _tokenAddress;

        thresholdPercent = _thresholdPercent;

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

    function addWallet(address _wallet, address _token, uint256 _timeValid) public {
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

    function getWallets() public view returns (WalletTest[] memory) {
        return walletTests;
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 currentTime = block.timestamp;

        for(uint256 i = 0; i < walletTests.length; i++) {
            if(currentTime > walletTests[i].expiry) {
                continue;
            }
            IERC20 token = IERC20(walletTests[i].token);

            uint256 oldBalance = walletTests[i].amount;
            uint256 newBalance = token.balanceOf(walletTests[i].wallet);

            if(newBalance < oldBalance * thresholdPercent / 100) {
                return false;
            }
        }

        return true;
    }
}
