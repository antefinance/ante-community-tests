// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/AnteTest.sol";

// Ante Test to check alUSD supply never exceeds amount of DAI locked in Alchemix
contract Ante_alUSDSupplyTest is AnteTest("alUSD doesn't exceed DAI locked in Alchemix") {
    // https://etherscan.io/address/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9
    address public constant alUSDAddr = 0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9;
    // https://etherscan.io/token/0x6B175474E89094C44Da98b954EedeAC495271d0F
    address public constant DAIAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // https://etherscan.io/address/0x19d3364a399d251e894ac732651be8b0e4e85001
    address public constant yvDAIAddr = 0x19D3364A399d251E894aC732651be8B0E4e85001;

    address public constant TransmuterAddr = 0xaB7A49B971AFdc7Ee26255038C82b4006D122086;
    address public constant AlchemistAddr = 0xc21D353FF4ee73C572425697f4F5aaD2109fe35b;
    address public constant TransmuterBAddr = 0xf3cFfaEEa177Db444b68FB6f033d4a82f6D8C82d;
    address public constant AlchemistYVAAddr = 0x014dE182c147f8663589d77eAdB109Bf86958f13;
    address public constant TransmuterBYVAddr = 0x491EAFC47D019B44e13Ef7cC649bbA51E15C61d7;

    IERC20 public DAIToken = IERC20(DAIAddr);
    IERC20 public alUSDToken = IERC20(alUSDAddr);
    IERC20 public yvDAIToken = IERC20(yvDAIAddr);

    constructor () {
        protocolName = "Alchemix";
        testedContracts = [alUSDAddr];
    }
    
    function checkTestPasses() public view override returns (bool) {
        uint TransmuterVL = DAIToken.balanceOf(TransmuterAddr) / 1e18;
        uint AlchemistVL = DAIToken.balanceOf(AlchemistAddr) / 1e18;
        uint TransmuterBVL = DAIToken.balanceOf(TransmuterBAddr) / 1e18;
        uint AlchemistYVAVL = yvDAIToken.balanceOf(AlchemistYVAAddr) / 1e18;
        uint TransmuterBYVAVL = yvDAIToken.balanceOf(TransmuterBYVAddr) / 1e18;
        uint TotalValueLocked = TransmuterVL + AlchemistVL + TransmuterBVL + AlchemistYVAVL + TransmuterBYVAVL;
        uint TotalSupply = alUSDToken.totalSupply() / 1e18;
        return (TotalSupply <= TotalValueLocked);
    }
    function CheckTransmuterVL() public view returns (uint) {
        return DAIToken.balanceOf(TransmuterAddr) / 1e18;
    }
    function CheckAlchemistVL() public view returns (uint) {
        return DAIToken.balanceOf(AlchemistAddr) / 1e18;
    }
    function CheckTransmuterBVL() public view returns (uint) {
        return DAIToken.balanceOf(TransmuterBAddr) / 1e18;
    }
    function CheckAlchemistYVAVL() public view returns (uint) {
        return yvDAIToken.balanceOf(AlchemistYVAAddr) / 1e18;
    }
    function CheckTransmuterBYVAVL() public view returns (uint) {
        return yvDAIToken.balanceOf(TransmuterBYVAddr) / 1e18;
    }
    function checkBalance() public view returns (uint) {
        uint TransmuterVL = DAIToken.balanceOf(TransmuterAddr) / 1e18;
        uint AlchemistVL = DAIToken.balanceOf(AlchemistAddr) / 1e18;
        uint TransmuterBVL = DAIToken.balanceOf(TransmuterBAddr) / 1e18;
        uint AlchemistYVAVL = yvDAIToken.balanceOf(AlchemistYVAAddr) / 1e18;
        uint TransmuterBYVAVL = yvDAIToken.balanceOf(TransmuterBYVAddr) / 1e18;
        return TransmuterVL + AlchemistVL + TransmuterBVL + AlchemistYVAVL + TransmuterBYVAVL;
    }
    function checkCirculating() public view returns (uint) {
        return alUSDToken.totalSupply() / 1e18;
    }
}