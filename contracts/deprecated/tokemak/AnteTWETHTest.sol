// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.7.0;

import "@openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-contracts-old/contracts/math/SafeMath.sol";
import "../../libraries/ante-v05-core/AnteTest.sol";
import "./interfaces/IManager.sol";
import "./interfaces/ILiquidityPool.sol";

/// @title Tokemak tWETH issued fully backed by WETH
/// @notice Ante Test to check Tokemak minted tWETH matches deposited WETH
contract AnteTWETHTest is AnteTest("Tokemak tWETH issued fully backed by WETH") {
    using SafeMath for uint256;

    IERC20 public wETH9Token;
    IERC20 public tWETHToken;
    IManager public tokemakManager;

    /// @param _tokemakManagerAddr Tokemak Pool Manager contract address (0xa86e412109f77c45a3bc1c5870b880492fb86a14 on mainnet)
    /// @param _tWETHAddr tWETH contract address (0xd3d13a578a53685b4ac36a1bab31912d2b2a2f36 on mainnet)
    /// @param _wETH9Addr WETH9 contract address (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 on mainnet)
    constructor(
        address _tokemakManagerAddr,
        address _tWETHAddr,
        address _wETH9Addr
    ) {
        wETH9Token = IERC20(_wETH9Addr);
        tWETHToken = IERC20(_tWETHAddr);

        tokemakManager = IManager(_tokemakManagerAddr);
        protocolName = "tWETH Pool";
        testedContracts = [_tWETHAddr, _tokemakManagerAddr];
    }

    /// @notice test to check tWETH token supply against total tokemak WETH balance
    /// @return true if tWETH token supply equals total WETH balance
    /// @dev Invariant holds for current tokemak implementation.
    /// @dev May not hold once liquidity deployment is implemented.
    function checkTestPasses() external view override returns (bool) {
        uint256 currentTVL;
        address[] memory pools;

        // During rollover, WETH could temporarily be moved to the manager, usually 0.
        currentTVL = currentTVL.add(wETH9Token.balanceOf(address(tokemakManager))); // in WETH

        pools = tokemakManager.getPools();
        for (uint256 i = 0; i < pools.length; i++) {
            ILiquidityPool pool = ILiquidityPool(pools[i]);
            // Pools has heterogeneous underlyers, only consider WETH pools
            if (address(pool.underlyer()) == address(wETH9Token)) {
                currentTVL = currentTVL.add(wETH9Token.balanceOf(pools[i]));
            }
        }
        return currentTVL >= tWETHToken.totalSupply();
    }
}
