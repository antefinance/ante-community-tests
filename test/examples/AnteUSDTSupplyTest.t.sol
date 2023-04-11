pragma solidity ^0.7.0;
pragma abicoder v2; // ????

import "forge-std/Test.sol";
import "../../contracts/examples/AnteUSDTSupplyTest.sol";

contract AnteUSDTSupplyTestTest is Test {
    uint256 mainnetFork;
    AnteUSDTSupplyTest public test;

    function setUp() public {
        mainnetFork = vm.createSelectFork(vm.rpcUrl("mainnet"));
        test = new AnteUSDTSupplyTest(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }

    function test_Passes() public {
        assertEq(test.checkTestPasses(), true);
    }
}