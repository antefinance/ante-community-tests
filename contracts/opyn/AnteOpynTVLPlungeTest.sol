pragma solidity ^0.8.0;

import "../AnteTest.sol";

/// @notice Checks if the TVL is at least 15% the original TVL
contract AnteOpynPlungeTest is AnteTest("Opyn Balance is greater than 15% the original") {
    // https://etherscan.io/token/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address private constant OPYN_ADDRESS = 0x64187ae08781B09368e6253F9E94951243A493D5;

    uint256 private immutable oldBalance;

    constructor() {
        protocolName = "Opyn";
        testedContracts = [OPYN_ADDRESS];

        oldBalance = OPYN_ADDRESS.balance;
    }

    /// @return if the TVL is at least 15% the original TVL
    function checkTestPasses() public view override returns (bool) {
        return (100 * OPYN_ADDRESS.balance / oldBalance > 15);
    }
}
