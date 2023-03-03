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

import "../libraries/ante-v05-core/AnteTest.sol";
import "../interfaces/IERC20.sol";
import "@openzeppelin-contracts-old/contracts/math/SafeMath.sol";

/// @title Compound comptroller issuance rate is not too fast
/// @notice Ante Test to check the decrease in the balance of COMP in the comptroller  doesn't exceed threshold
/// currently 10,000 COMP/day
contract AnteComptrollerIssuanceTest is AnteTest("$COMP (Comptroller) Issuance Rate Test") {
    using SafeMath for uint256;

    /// @notice minimum period after checkpointing before checkTestPasses call
    /// is allowed to fail
    uint32 public constant MIN_PERIOD = 12 hours;
    /// @notice minimum interval between allowing subsequent checkpoints
    /// @dev prevents malicious stakers from preventing a failing test by calling checkpoint() repeatedly
    uint32 public constant MIN_CHECKPOINT_INTERVAL = 48 hours;

    /// @notice maximum rate of COMP decrease per second allowed, set to 10,000 COMP/day
    /// @dev according to https://compound.finance/governance/comp as of 2021/10/05
    /// the current rate of COMP distribution per day is 2312, so we set this conservatively
    /// to 10,000 COMP/day (set in units of COMP/second). It's possible to trigger a
    /// failing test with a smaller decrese in COMP balance depending on the MIN_PERIOD parameter
    uint256 public constant COMP_PER_SEC_THRESHOLD = 115740740740740736;

    /// @notice last time a checkpoint was taken
    uint256 public lastCheckpointTime;
    /// @notice COMP balance at last checkpoint
    uint256 public lastCompBalance;

    /// @notice Compound comptroller address
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    /// @notice COMP token
    IERC20 public constant COMP = IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    constructor() {
        protocolName = "Compound";
        testedContracts = [COMPTROLLER, address(COMP)];

        checkpoint();
    }

    /// @notice take checkpoint of current COMP balance
    function checkpoint() public {
        require(
            block.timestamp.sub(lastCheckpointTime) > MIN_CHECKPOINT_INTERVAL,
            "Cannot call checkpoint more than once every 48 hours"
        );

        lastCheckpointTime = block.timestamp;
        lastCompBalance = COMP.balanceOf(COMPTROLLER);
    }

    /// @notice checks that COMP balance of comptroller doesn't decrease by more than 10,000 COMP/day
    /// @dev returns true if less than MIN_PERIOD has passed since last checkpoint or if COMP balance
    /// increases to avoid reversion
    /// @return true if comptroller COMP balance increases or deosn't decrease by less than 10,000 COMP/day
    function checkTestPasses() public view override returns (bool) {
        uint256 timeSinceLastCheckpoint = block.timestamp.sub(lastCheckpointTime);
        if (timeSinceLastCheckpoint > MIN_PERIOD) {
            uint256 compBalance = COMP.balanceOf(COMPTROLLER);
            // if COMP was added to contract then return true to avoid reversion due to underflow
            if (compBalance >= lastCompBalance) {
                return true;
            }

            return lastCompBalance.sub(compBalance).div(timeSinceLastCheckpoint) < COMP_PER_SEC_THRESHOLD;
        }

        // if timeSinceLastCheckpoint is less than MIN_PERIOD just return true
        // don't revert test since this will trigger failure on associated AntePool
        return true;
    }
}
