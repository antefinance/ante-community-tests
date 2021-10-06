// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/// @title Compound comptroller doesn't lose COMP balance too quickly
/// @notice Ante Test to check the decrease in the balance of COMP in the comptroller  doesn't exceed threshold
/// currently 10,000 COMP/day
contract AnteCompoundComptrollerTest is AnteTest("Compound comptroller doesn't lose COMP balance too quickly") {
    using SafeMath for uint256;

    /// @notice minimum period after checkpointing before checkTestPasses call
    /// is allowed to fail
    uint32 public constant MIN_PERIOD = 12 hours;
    /// @notice period after checkpoint taken in which only checkpointer
    /// is able to fail the test
    /// @dev this protects the verifier bounty from being frontrun by other challengers
    uint32 public constant PROTECTED_PERIOD = 14 hours;
    /// @notice minimum interval between allowing subsequent checkpoints
    /// @dev prevents malicious stakers from preventing a failing test by calling checkpoint() repeatedly
    uint32 public constant MIN_CHECKPOINT_INTERVAL = 24 hours;

    /// @notice maximum rate of COMP decrease per second allowed, set to 10,000 COMP/day
    /// @dev according to https://compound.finance/governance/comp as of 2021/10/05
    /// the current rate of COMP distribution per day is 2312, so we set this conservatively
    /// to 10,000 COMP/day (set in units of COMP/second)
    uint256 public constant COMP_PER_SEC_THRESHOLD = 115740740740740736;

    /// @notice last time a checkpoint was taken
    uint256 public lastCheckpointTime;
    /// @notice COMP balance at last checkpoint
    uint256 public lastCompBalance;

    /// @notice address which called checkpoint() to prime test
    address public checkpointer;
    /// @notice Compound comptroller address
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    /// @notice COMP token
    IERC20 public constant COMP = IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    constructor() {
        protocolName = "Compound";
        testedContracts = [COMPTROLLER, address(COMP)];

        checkpoint();
    }

    /// @notice convenience function to check if enough time has elapsed after previous checkpoint
    /// to check COMP balance change
    /// @return true is checkTestPasses() can currently fail, false otherwise
    function testCallable() external view returns (bool) {
        return (block.timestamp.sub(lastCheckpointTime) > MIN_PERIOD);
    }

    /// @notice take checkpoint of current COMP balance
    function checkpoint() public {
        require(
            block.timestamp.sub(lastCheckpointTime) > MIN_CHECKPOINT_INTERVAL,
            "Cannot call checkpoint more than once every 24 hours"
        );

        lastCheckpointTime = block.timestamp;
        lastCompBalance = COMP.balanceOf(COMPTROLLER);
        checkpointer = msg.sender;
    }

    function checkTestPasses() public view override returns (bool) {
        uint256 timeSinceLastCheckpoint = block.timestamp.sub(lastCheckpointTime);
        if (timeSinceLastCheckpoint > MIN_PERIOD) {
            if (msg.sender != checkpointer && timeSinceLastCheckpoint < PROTECTED_PERIOD) {
                // only checkpointer can trigger failing test in protected period
                return true;
            }

            return
                COMP.balanceOf(COMPTROLLER).sub(lastCompBalance).div(timeSinceLastCheckpoint) > COMP_PER_SEC_THRESHOLD;
        }

        // if timeSinceLastCheckpoint is less than MIN_PERIOD just return true
        // don't revert test since this will trigger failure on associated AntePool
        return true;
    }
}
