pragma solidity ^0.7.0;
pragma abicoder v2; // ????

import "forge-std/Test.sol";
import "../../contracts/examples/AnteUSDTSupplyTest.sol";

contract AnteUSDTSupplyTestTest is Test {
    uint256 mainnetFork;
    AnteUSDTSupplyTest public test;

    string MAINNET_RPC_URL = string(abi.encodePacked(
        "https://eth-mainnet.g.alchemy.com/v2/", 
        vm.envString("ALCHEMY_KEY")
    ));

    function setUp() public {
        mainnetFork = vm.createSelectFork(MAINNET_RPC_URL);
        test = new AnteUSDTSupplyTest(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }

    function test_Passes() public {
        assertEq(test.checkTestPasses(), true);
    }
}