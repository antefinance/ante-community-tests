// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "./interfaces/IPrimitiveEngine.sol";

contract AntePrimitiveReplicationTest is AnteTest("Checks Primitive RMM-01 replicates covered call payoff") {
    // convenience event to see test result in logs
    event CheckTestPasses(bool indexed passing);

    // terminal error of pool in units of PRECISION
    mapping(bytes32 => uint256) public terminalError;
    mapping(bytes32 => bool) public checked;

    mapping(bytes32 => bool) _poolIdPresent;
    bytes32[] public poolIds;
    IPrimitiveEngine public primitiveEngine;

    // buffer after maturity for pool to be considered expired
    uint256 immutable _buffer;

    // probably overkill
    uint256 constant PRECISION = 10**18;
    // equivalent to 10%
    // TODO: discuss this bound
    uint256 constant TOLERANCE = (PRECISION * 90) / 100;

    // couldn't find a place where the list of poolIds was stored
    // in the manager or core repo, so just provide functionality to
    // initialize and update the poolIds here
    constructor(IPrimitiveEngine _primitiveEngine, bytes32[] memory _poolIds) {
        primitiveEngine = _primitiveEngine;
        addPoolIds(_poolIds);

        _buffer = primitiveEngine.BUFFER();
    }

    // TODO: current criteria is one failing pool fails the test, can switch to M-of-N criteria
    function checkTestPasses() external override returns (bool) {
        for (uint256 i = 0; i < poolIds.length; i++) {
            bool passing = _checkPool(poolIds[i]);
            if (!passing) return false;
        }

        return true;
    }

    // poolIds from the array will NOT be added to existing list of poolIds unless
    // those pools are not expired
    // TODO: probably want to implement a sanity check/access control here so people can't add pools
    // with crappy parameters and trigger a test failure
    // TODO: also prune poolIds for those which have already been checked
    function addPoolIds(bytes32[] memory _poolIds) public {
        for (uint256 i = 0; i < _poolIds.length; i++) {
            bytes32 poolId = _poolIds[i];
            (, , uint32 maturity, , ) = primitiveEngine.calibrations(poolId);
            // poolId won't be added if not present because maturity will be set to 0
            if (block.timestamp < maturity && !_poolIdPresent[poolId]) {
                poolIds.push(poolId);
                _poolIdPresent[poolId] = true;
            }
        }
    }

    // TODO: discuss boundary conditions - what are feasible values of reserveRisky after expiry
    // what happens if all liquidity removed from pool, etc.
    function _checkPool(bytes32 poolId) internal returns (bool) {
        // pool is only marked as checked if checked after expiry+BUFFER
        // result won't change so no need to recheck
        if (checked[poolId]) return true;

        (uint128 strike, , uint32 maturity, , ) = primitiveEngine.calibrations(poolId);
        // strike set be zero indicates no pool was found for this poolId
        if (strike == 0) return true;

        // don't check pool unless after expiry
        if (block.timestamp < maturity + _buffer) return true;

        (uint128 reserveRisky, uint128 reserveStable, uint128 liquidity, , , , ) = primitiveEngine.reserves(poolId);

        uint256 liq = uint256(liquidity);
        uint256 normRisky = (PRECISION * uint256(reserveRisky)) / liq;
        uint256 normStable = (PRECISION * uint256(reserveStable)) / liq;

        // make assumption that liquidity-normalized reserveRisky is > 0.1 iff S < K after expiry
        uint256 _terminalError;
        if (normRisky < PRECISION / 10) {
            _terminalError = normStable / strike;
        } else {
            _terminalError = normRisky;
        }

        checked[poolId] = true;
        terminalError[poolId] = _terminalError;

        // TODO: check upper bound too? I assume we don't care if LP payoff is higher than expected
        emit CheckTestPasses(_terminalError > TOLERANCE);
        return _terminalError > TOLERANCE;
    }
}
