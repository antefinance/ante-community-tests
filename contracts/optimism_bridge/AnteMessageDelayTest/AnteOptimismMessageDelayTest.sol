// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AnteTest} from "../../AnteTest.sol";
import {ICrossDomainMessenger} from "../ICrossDomainMessenger.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error InvalidAddress();
error OnlyOwner();

/// @title Optimism Bridge updates messages as stated Test
/// @notice Ante Test to check if Optimism Bridge deliveres messages from L1 to L2 in less than 20 mins
contract AnteOptimismMessageDelayTest is
    AnteTest("Optimism Bridge message doesn't take more than 20 mins from L1 to L2")
{
    address public owner;
    address public l1Controller;
    address public ovmL2CrossDomainMessenger = 0x4200000000000000000000000000000000000007;
    mapping(address => uint256) public submittedTimestamps;
    mapping(address => uint256) public receivedTimestamps;
    address private caller;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    modifier onlyMessenger() {
        if (
            msg.sender != address(ovmL2CrossDomainMessenger) ||
            ICrossDomainMessenger(ovmL2CrossDomainMessenger).xDomainMessageSender() != l1Controller
        ) {
            revert InvalidAddress();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
        protocolName = "Optimism Bridge";
        testedContracts = [ovmL2CrossDomainMessenger];
    }

    function setController(address _controller) external onlyOwner {
        l1Controller = _controller;
        // Destroy the owner after controller is set.
        owner = address(0);
    }

    function setTimestamp(bytes memory _state) external onlyMessenger {
        (address user, uint256 submittedTimestamp) = abi.decode(_state, (address, uint256));
        submittedTimestamps[user] = submittedTimestamp;
        receivedTimestamps[user] = block.timestamp;
    }

    function getStateTypes() external pure virtual override returns (string memory) {
        return "address";
    }

    function getStateNames() external pure virtual override returns (string memory) {
        return "caller";
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
}
