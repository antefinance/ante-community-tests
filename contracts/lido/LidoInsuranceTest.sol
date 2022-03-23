// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../AnteTest.sol";

contract AnteLidoInsuranceTest is AnteTest("Make sure at least 0.5% of Lido stake is insured!") {
    address public immutable lidoContract;
    address public immutable lidoInsuranceContract;

    constructor (address _lidoContract, address _lidoInsuranceContract) {
        lidoContract = _lidoContract;
        lidoInsuranceContract = _lidoInsuranceContract;
        protocolName = "Lido Staking ";
        testedContracts = [0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84];
    }
    
    function checkTestPasses() public view override returns (bool) {

        /* 
         * Solidity doesn't support decimals (yet). So where x / y < 1; solidity will
         * cut off the decimals and "round to 0". 
         *
         * To avoid this issue, we use a slightly modified equation
         *
         * x / y >= 0.005
         * x >= 0.005 * y
         * x >= y * 5 / 1000 
        */
        return (lidoInsuranceContract.balance >= lidoContract.balance * 5 / 1000);
    }

    function getInsurancePercentageInverse() public view returns(uint256) {
        // To get the percentage you do 1 / return value * 100
        return (lidoContract.balance / lidoInsuranceContract.balance);
    }
}
