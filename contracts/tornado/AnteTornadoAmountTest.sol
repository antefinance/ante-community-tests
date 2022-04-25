pragma solidity ^0.7.0;

import "../AnteTest.sol";

contract AnteTornadoAmountTest is
    AnteTest(
        "Tornado ETH pools don't fall below 1% of their supply at the time of deployment"
    )
{
    address public constant torn100Addr =
        0xA160cdAB225685dA1d56aa342Ad8841c3b53f291;
    address public constant torn10Addr =
        0x910Cbd523D972eb0a6f4cAe4618aD62622b39DbF;
    address public constant torn1Addr =
        0x47CE0C6eD5B0Ce3d3A51fdb1C52DC66a7c3c2936;
    address public constant torn01Addr =
        0x12D66f87A04A9E220743712cE6d9bB1B5616B8Fc;

    // deployed contract has these as internal visibility rather than public
    // public would have been better though
    uint256 public immutable torn100BalanceAtDeploy;
    uint256 public immutable torn10BalanceAtDeploy;
    uint256 public immutable torn1BalanceAtDeploy;
    uint256 public immutable torn01BalanceAtDeploy;

    constructor() {
        protocolName = "Tornado Cash";
        testedContracts = [torn100Addr, torn10Addr, torn1Addr, torn01Addr];
        torn100BalanceAtDeploy = torn100Addr.balance;
        torn10BalanceAtDeploy = torn10Addr.balance;
        torn1BalanceAtDeploy = torn1Addr.balance;
        torn01BalanceAtDeploy = torn01Addr.balance;
    }

    function checkTestPasses() public view override returns (bool) {
        return ((torn100BalanceAtDeploy / 100) < torn100Addr.balance &&
            (torn10BalanceAtDeploy / 100) < torn10Addr.balance &&
            (torn1BalanceAtDeploy / 100) < torn1Addr.balance &&
            (torn01BalanceAtDeploy / 100) < torn01Addr.balance);
    }

}
