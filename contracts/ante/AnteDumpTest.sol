// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";

struct WalletTest {
    address wallet;
    address token;
    uint256 amount;
}

contract AnteDumpTest is AnteTest("USDC is above 90 cents on the dollar") {
    WalletTest[] private walletTests;

    uint8 private immutable thresholdPercent;

    constructor(address[] memory  _tokenAddress, address[] memory _monitorWallet, uint8 _thresholdPercent) {
        protocolName = "Ante";
        testedContracts = _tokenAddress;

        thresholdPercent = _thresholdPercent;

        for(uint256 i = 0; i < _monitorWallet.length; i++) {
            IERC20 token = IERC20(_tokenAddress[i]);

            WalletTest memory walletTest;

            walletTest.wallet = _monitorWallet[i];
            walletTest.token = _tokenAddress[i];
            walletTest.amount = token.balanceOf(_monitorWallet[i]);

            walletTests.push(walletTest);
        }
    }

    function addWallet(address _wallet, address _token) public {
        IERC20 token = IERC20(_token);

        WalletTest memory walletTest;

        walletTest.wallet = _wallet;
        walletTest.token = _token;
        walletTest.amount = token.balanceOf(_wallet);

        walletTests.push(walletTest);
    }

    function checkTestPasses() public view override returns (bool) {

        for(uint256 i = 0; i < walletTests.length; i++) {
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
