// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AnteTest.sol";

contract MyAnteTest is AnteTest("Make sure at least 0.5% of Lido stake is insured!") {
    address lidoContract = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address lidoInsuranceContract = 0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c;

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
         * To avoid this issue, we can use the inverse percentage.
         * 
         * Let x = contract balance and y = insurance balance
         *
         * Note, we are ensuring 0.5% is insured. 0.5 / 100 = 0.005 and 100 / 0.5 = 200;
         *
         * Generally we would do x / y > 0.5 but since we are inversing the percentage
         * we flip the inequality sign. So we get: y / x < 200;
        */
        return (lidoContract.balance / lidoInsuranceContract.balance) < 200;
    }

    function getInsurancePercentageInverse() public view returns(uint256) {
        // To get the percentage you do 1 / return value * 100
        return (lidoContract.balance / lidoInsuranceContract.balance);
    }
}
