// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../AnteTest.sol";

// @title Lido Insurance Test 
// @author github.com/icepaq
// @notice ensures at least 0.5% of Lido stake is insured
contract AnteLidoInsuranceTest is AnteTest("Make sure at least 0.5% of Lido stake is insured!") {
    address public immutable lidoContract;
    address public immutable lidoInsuranceContract;

    // @param _lidoContract Address of lido contract
    // @param _lidoInsuranceContract Address of lido insurance contract
    constructor (address _lidoContract, address _lidoInsuranceContract) {
        lidoContract = _lidoContract;
        lidoInsuranceContract = _lidoInsuranceContract;
        protocolName = "Lido";
        testedContracts = [_lidoContract, _lidoInsuranceContract];
    }
    
    // @notice returns true if at least 0.5% of stake is insured
    // @notice returns false if less than 0.5% of stake is insured
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

    // @notice To get the percentage you do 1 / return value * 100
    // @return the inverse percentage of the contract insurance reserve
    function getInsurancePercentageInverse() public view returns(uint256) {
        return (lidoContract.balance / lidoInsuranceContract.balance);
    }
}
