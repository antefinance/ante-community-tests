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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../AnteTest.sol";

/// @title Ante Test to check BalancerV2 token supply
/// @dev We are snapshotting the balance of selected tokens for the balancerV2
/// We expect the invariant to hold that the balance of each of these coins
/// will not dip below 10% of their value at the time of the deployment of this test
contract AllNetworksAnteBalancerV2TokenBalanceTest is
    AnteTest("Balancer major token balances do not drop 90% from time of test deployment")
{
    address public immutable balancerAddr;
    IERC20[] public tokens;

    mapping(address=>uint256) public deploymentBalances;

    /// @param _balancerAddr balancerV2 contract address 
    /// @param _tokens array of token addresses
    constructor(
        address _balancerAddr, address[] memory _tokens
    ) {
        balancerAddr = _balancerAddr;
        
        for(uint256 tokenIndex = 0; tokenIndex < _tokens.length; tokenIndex++){
          tokens.push(IERC20(_tokens[tokenIndex]));
          deploymentBalances[_tokens[tokenIndex]] = tokens[tokenIndex].balanceOf(_balancerAddr);
        }

        protocolName = "BalancerV2";
        testedContracts = [_balancerAddr];
        
    }

    /// @notice test to check if Tokens balances fall below
    /// 10% of their amount since deployment.
    function checkTestPasses() external view override returns (bool) {

      for(uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++){
        if (tokens[tokenIndex].balanceOf(balancerAddr) * 100 <= deploymentBalances[address(tokens[tokenIndex])] * 10) {
          return false;
        }
      }
      return true;
    }
}
