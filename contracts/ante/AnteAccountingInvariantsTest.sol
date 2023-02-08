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

import "../libraries/ante-v06-core/AnteTest.sol";
import "../libraries/ante-v06-core/interfaces/IAntePoolFactory.sol";
import "../libraries/ante-v06-core/interfaces/IAntePool.sol";

/// @title Some of Ante's accounting invariants are not broken
/// @notice Ante Test to check that for each pool, challengerInfo.numUsers > 0 if eligibilityInfo > 0
contract AnteAccountingInvariantsTest is AnteTest("Some of Ante's accounting invariants are not broken") {
    address public immutable factoryContractAddr;

    uint private poolIndex = 0;

    /// @param _factoryContractAddr Ante factory address
    constructor(address _factoryContractAddr) {
        protocolName = "Ante";
        factoryContractAddr = _factoryContractAddr;
        testedContracts = [factoryContractAddr];
    }

    function checkTestPasses() public view override returns (bool) {
        IAntePoolFactory factory = IAntePoolFactory(factoryContractAddr);
        require(poolIndex < factory.numPools(), "ANTE: poolIndex out of bounds"); // let the test pass
        address poolAddress = factory.allPools(poolIndex);
        IAntePool pool = IAntePool(poolAddress);

        // Invariant: challengerInfo.numUsers > 0 if eligibilityInfo > 0
        (uint256 challengeUsers,,) = pool.challengerInfo();
        if (pool.eligibilityInfo() > 0 && !(
            challengeUsers > 0))
                return false;

        return true;
    }

    /// @param data the state passed by checkTestWithState
    function _setState(bytes memory data) internal override virtual {
        poolIndex = abi.decode(data, (uint));
    }

    function getStateTypes() external pure override returns (string memory) {
        return "uint";
    }

    function getStateNames() external pure override returns (string memory) {
        return "poolIndex";
    }
}
