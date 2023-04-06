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
    /// @notice The address of L1 contract that is allowed to register the state
    address public l1Controller;

    /// @notice https://optimistic.etherscan.io/address/0x4200000000000000000000000000000000000007
    address public ovmL2CrossDomainMessenger = 0x4200000000000000000000000000000000000007;

    /// @notice Mapping that stores the message submitted timestamp for a specific caller
    mapping(address => uint256) public submittedTimestamps;
    /// @notice Mapping that stores the message received timestamp for a specific caller
    mapping(address => uint256) public receivedTimestamps;
    /// @notice The address used to test the invariant
    address private caller;

    modifier onlyMessenger() {
        if (
            msg.sender != address(ovmL2CrossDomainMessenger) ||
            ICrossDomainMessenger(ovmL2CrossDomainMessenger).xDomainMessageSender() != l1Controller
        ) {
            revert InvalidAddress();
        }
        _;
    }

    constructor(address _controller) {
        l1Controller = _controller;
        protocolName = "Optimism Bridge";
        testedContracts = [ovmL2CrossDomainMessenger];
    }

    function setTimestamp(bytes memory _state) external onlyMessenger {
        (address user, uint256 submittedTimestamp) = abi.decode(_state, (address, uint256));
        submittedTimestamps[user] = submittedTimestamp;
        receivedTimestamps[user] = block.timestamp;
    }

    /// @inheritdoc AnteTest
    function getStateTypes() external pure virtual override returns (string memory) {
        return "address";
    }

    /// @inheritdoc AnteTest
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
