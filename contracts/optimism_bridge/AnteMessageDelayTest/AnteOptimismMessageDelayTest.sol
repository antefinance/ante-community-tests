// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../../AnteTest.sol";
import {ICrossDomainMessenger} from "../ICrossDomainMessenger.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error InvalidAddress();

/// @title Optimism Bridge updates messages as stated Test
/// @notice Ante Test to check if Optimism Bridge deliveres messages from L1 to L2 in less than 20 mins
contract AnteOptimismMessageDelayTest is
    AnteTest("Optimism Bridge message doesn't take more than 20 mins from L1 to L2")
{
    mapping(address => uint256) public submittedTimestamps;
    mapping(address => uint256) public receivedTimestamps;
    address private caller;

    modifier onlyMessenger() {
        address messengerAddr = getXorig();
        if (messengerAddr == address(0)) {
            revert InvalidAddress();
        }
        _;
    }

    constructor() {
        protocolName = "Optimism Bridge";
        testedContracts = [0x4200000000000000000000000000000000000007];
    }

    function getStateTypes() external pure virtual override returns (string memory) {
        return "address";
    }

    function getStateNames() external pure virtual override returns (string memory) {
        return "caller";
    }

    function setTimestamp(bytes memory _state) public onlyMessenger {
        (address user, uint256 submittedTimestamp) = abi.decode(_state, (address, uint256));
        submittedTimestamps[user] = submittedTimestamp;
        receivedTimestamps[user] = block.timestamp;
    }

    /// @notice test to check if message took more than 20 mins to be propagated from L1 to L2
    /// @return true if checked on L2 and message took more less than 20 mins to be delivered
    function checkTestPasses() public view override returns (bool) {
        // Pass the test on chains that are not Optimism L2
        if (block.chainid != 10 && block.chainid != 420 && block.chainid != 31337) return true;

        if (receivedTimestamps[caller] - submittedTimestamps[caller] > 20 minutes) {
            return false;
        }

        return true;
    }

    function _setState(bytes memory _state) internal override {
        caller = abi.decode(_state, (address));
    }

    // Get the cross domain origin, if any
    function getXorig() private view returns (address) {
        // Get the cross domain messenger's address each time.
        // This is less resource intensive than writing to storage.
        address cdmAddr = address(0);

        // Mainnet
        if (block.chainid == 1) cdmAddr = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;

        // Goerli
        if (block.chainid == 5) cdmAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

        // L2 (same address on every network)
        if (block.chainid == 10 || block.chainid == 420 || block.chainid == 31337) cdmAddr = 0x4200000000000000000000000000000000000007;

        // If this isn't a cross domain message
        if (msg.sender != cdmAddr) return address(0);

        // If it is a cross domain message, find out where it is from
        return ICrossDomainMessenger(cdmAddr).xDomainMessageSender();
    }
}
