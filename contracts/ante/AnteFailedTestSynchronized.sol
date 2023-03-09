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
import "../libraries/ante-v06-core/interfaces/IAntePool.sol";
import "../libraries/ante-v06-core/interfaces/IAntePoolFactory.sol";

//not exposed so we just copy
struct TestStateInfo {
    bool hasFailed;
    address verifier;
    uint256 failedBlock;
    uint256 failedTimestamp;
}


/// @title Ante's test states are synchronized
/// @notice Ante Test to check that each pool for a given test have failedBlock and failedTimestamp synchronized with the factory's TestStateInfo
contract AnteTestStatePushedTest is AnteTest("TestStateInfo information is pushed to registered pools") {
    address public immutable factoryContractAddr;

    address private testAddr = address(0);

    /// @param _factoryContractAddr Ante factory address
    constructor(address _factoryContractAddr) {
        protocolName = "Ante";
        factoryContractAddr = _factoryContractAddr;
        testedContracts = [factoryContractAddr];
    }

    function checkTestPasses() public view override returns (bool) {
        IAntePoolFactory factory = IAntePoolFactory(factoryContractAddr);
        require(factory.getPoolsByTest(testAddr).length > 0, "ANTE: testAddr is not a registered test"); // must have at least 1 pool

        bool testHasFailed = factory.hasTestFailed(testAddr);
        address[] memory pools = factory.getPoolsByTest(testAddr);

        for (uint i = 0; i < pools.length; i += 1) { // capped at MAX_POOLS_PER_TEST=10 so gas bombing shouldn't be a problem
            IAntePool pool = IAntePool(pools[i]);
            if (testHasFailed && pool.failedBlock() == 0) return false;
            if (testHasFailed && pool.failedTimestamp() == 0) return false;
        }

        return true;
    }
    /// @param data the state passed by checkTestWithState
    function _setState(bytes memory data) internal override virtual {
        testAddr = abi.decode(data, (address));
    }

    function getStateTypes() external pure override returns (string memory) {
        return "address";
    }

    function getStateNames() external pure override returns (string memory) {
        return "testAddr";
    }
}
