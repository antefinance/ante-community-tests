// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../../interfaces/IERC20.sol";
import "../../AnteTest.sol";

interface IVault {
    function pricePerShare() external view returns (uint256);
}

// Ante Test to check alUSD supply never exceeds amount of DAI locked in Alchemix
contract Ante_alUSDSupplyTest is AnteTest("alUSD doesn't exceed DAI locked in Alchemix") {
    // https://etherscan.io/address/0xbc6da0fe9ad5f3b0d58160288917aa56653660e9
    address public constant alUSDAddr = 0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9;
    // https://etherscan.io/token/0x6B175474E89094C44Da98b954EedeAC495271d0F
    address public constant DAIAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // https://etherscan.io/address/0xdA816459F1AB5631232FE5e97a05BBBb94970c95
    address public constant yvDAIAddr = 0xdA816459F1AB5631232FE5e97a05BBBb94970c95;

    address public constant AlchemistAddr = 0xc21D353FF4ee73C572425697f4F5aaD2109fe35b;
    address public constant TransmuterAddr = 0xaB7A49B971AFdc7Ee26255038C82b4006D122086;
    address public constant TransmuterBAddr = 0xeE69BD81Bd056339368c97c4B2837B4Dc4b796E7;
    address public constant AlchemistYVAAddr = 0xb039eA6153c827e59b620bDCd974F7bbFe68214A;
    address public constant TransmuterBYVAddr = 0x6Fe02BE0EC79dCF582cBDB936D7037d2eB17F661;

    IERC20 public DAIToken = IERC20(DAIAddr);
    IERC20 public alUSDToken = IERC20(alUSDAddr);
    IERC20 public yvDAIToken = IERC20(yvDAIAddr);
    IVault public yvDAIVault = IVault(yvDAIAddr);

    constructor() {
        protocolName = "Alchemix";
        testedContracts = [alUSDAddr];
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 TransmuterVL = DAIToken.balanceOf(TransmuterAddr) / 1e18;
        uint256 AlchemistVL = DAIToken.balanceOf(AlchemistAddr) / 1e18;
        uint256 TransmuterBVL = DAIToken.balanceOf(TransmuterBAddr) / 1e18;
        uint256 PricePerShare = yvDAIVault.pricePerShare();
        uint256 AlchemistYVAVL = (yvDAIToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
        uint256 TransmuterBYVAVL = (yvDAIToken.balanceOf(TransmuterBYVAddr) * PricePerShare) / 1e36;
        uint256 TotalValueLocked = TransmuterVL + AlchemistVL + TransmuterBVL + AlchemistYVAVL + TransmuterBYVAVL;
        uint256 TotalSupply = alUSDToken.totalSupply() / 1e18;
        return (TotalSupply <= TotalValueLocked);
    }

    function checkTransmuterVL() public view returns (uint256) {
        return DAIToken.balanceOf(TransmuterAddr) / 1e18;
    }

    function checkAlchemistVL() public view returns (uint256) {
        return DAIToken.balanceOf(AlchemistAddr) / 1e18;
    }

    function checkTransmuterBVL() public view returns (uint256) {
        return DAIToken.balanceOf(TransmuterBAddr) / 1e18;
    }

    function checkAlchemistYVAVL() public view returns (uint256) {
        uint256 PricePerShare = yvDAIVault.pricePerShare();
        return (yvDAIToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
    }

    function checkTransmuterBYVAVL() public view returns (uint256) {
        uint256 PricePerShare = yvDAIVault.pricePerShare();
        return (yvDAIToken.balanceOf(TransmuterBYVAddr) * PricePerShare) / 1e36;
    }

    function checkBalance() public view returns (uint256) {
        uint256 TransmuterVL = DAIToken.balanceOf(TransmuterAddr) / 1e18;
        uint256 AlchemistVL = DAIToken.balanceOf(AlchemistAddr) / 1e18;
        uint256 TransmuterBVL = DAIToken.balanceOf(TransmuterBAddr) / 1e18;
        uint256 PricePerShare = yvDAIVault.pricePerShare();
        uint256 AlchemistYVAVL = (yvDAIToken.balanceOf(AlchemistYVAAddr) * PricePerShare) / 1e36;
        uint256 TransmuterBYVAVL = (yvDAIToken.balanceOf(TransmuterBYVAddr) * PricePerShare) / 1e36;
        return TransmuterVL + AlchemistVL + TransmuterBVL + AlchemistYVAVL + TransmuterBYVAVL;
    }

    function checkCirculating() public view returns (uint256) {
        return alUSDToken.totalSupply() / 1e18;
    }
}
