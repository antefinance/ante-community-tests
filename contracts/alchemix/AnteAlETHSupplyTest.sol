// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../AnteTest.sol";

// NB: As of 1/4/22 this test is currently failing on mainnet
// total ETH tvl across all addresses below is 79703 and alETH supply is 85633
interface IVault {
    function pricePerShare() external view returns (uint256);
}

// Ante Test to check alETH supply never exceeds amount of ETH locked in Alchemix
contract AnteAlETHSupplyTest is AnteTest("alETH doesn't exceed ETH locked in Alchemix") {
    // https://etherscan.io/address/0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6
    address public constant alETHAddr = 0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6;
    // https://etherscan.io/token/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    address public constant WETHAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // https://etherscan.io/address/0xa258C4606Ca8206D8aA700cE2143D7db854D168c
    address public constant yvWETHAddr = 0xa258C4606Ca8206D8aA700cE2143D7db854D168c;

    address public constant TransmuterAddr = 0x9FD9946E526357B35D95Bcb4b388614be4cFd4AC;
    address public constant AlchemistAddr = 0x6B566554378477490ab040f6F757171c967D03ab;
    address public constant AlchemistYVAAddr = 0xEBA649E0010818Aa4321088D34bD6162d65E7971;
    address public constant TransmuterYVAddr = 0x6d75657771256C7a8CB4d475fDf5047B70160132;

    IERC20 public alETHToken = IERC20(alETHAddr);
    IERC20 public WETHToken = IERC20(WETHAddr);
    IERC20 public yvWETHToken = IERC20(yvWETHAddr);
    IVault public yvWETHVault = IVault(yvWETHAddr);

    constructor() {
        protocolName = "Alchemix";
        testedContracts = [alETHAddr];
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 TransmuterVL = WETHToken.balanceOf(TransmuterAddr) / 1e18;
        uint256 AlchemistVL = WETHToken.balanceOf(AlchemistAddr) / 1e18;
        uint256 PricePerShare = yvWETHVault.pricePerShare();
        uint256 AlchemistYVAVL = (yvWETHToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
        uint256 TransmuterBYVAVL = (yvWETHToken.balanceOf(TransmuterYVAddr) * PricePerShare) / 1e36;
        uint256 TotalValueLocked = TransmuterVL + AlchemistVL + AlchemistYVAVL + TransmuterBYVAVL;
        uint256 TotalSupply = alETHToken.totalSupply() / 1e18;
        return (TotalSupply <= TotalValueLocked);
    }

    function checkTransmuterVL() public view returns (uint256) {
        return WETHToken.balanceOf(TransmuterAddr) / 1e18;
    }

    function checkAlchemistVL() public view returns (uint256) {
        return WETHToken.balanceOf(AlchemistAddr) / 1e18;
    }

    function checkAlchemistYVAVL() public view returns (uint256) {
        uint256 PricePerShare = yvWETHVault.pricePerShare();
        return (yvWETHToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
    }

    function checkTransmuterBYVAVL() public view returns (uint256) {
        uint256 PricePerShare = yvWETHVault.pricePerShare();
        return (yvWETHToken.balanceOf(TransmuterYVAddr) * PricePerShare) / 1e36;
    }

    function checkBalance() public view returns (uint256) {
        uint256 TransmuterVL = WETHToken.balanceOf(TransmuterAddr) / 1e18;
        uint256 AlchemistVL = WETHToken.balanceOf(AlchemistAddr) / 1e18;
        uint256 PricePerShare = yvWETHVault.pricePerShare();
        uint256 AlchemistYVAVL = (yvWETHToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
        uint256 TransmuterBYVAVL = (yvWETHToken.balanceOf(TransmuterYVAddr) * PricePerShare) / 1e36;
        return TransmuterVL + AlchemistVL + AlchemistYVAVL + TransmuterBYVAVL;
    }

    function checkCirculating() public view returns (uint256) {
        return alETHToken.totalSupply() / 1e18;
    }
}
