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

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title  Cobie doesn't rug Do-Algod-DCR escrow wallet
/// @notice Ante Test to check if the USDC + USDT balance of the Do-Algod-DCR LUNA bet 
///         escrow wallet drops below 22M before 2023-03-14 
contract AnteCobieRugTest is AnteTest("Cobie Doesnt Rug Do-Algod-DCR Escrow Wallet") {
    // https://etherscan.io/address/0x4Cbe68d825d21cB4978F56815613eeD06Cf30152
    address public constant ESCROW_ADDR = 0x4Cbe68d825d21cB4978F56815613eeD06Cf30152;
    // https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    IERC20Metadata public constant USDC = IERC20Metadata(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    // https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7
    IERC20Metadata public constant USDT = IERC20Metadata(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // Bet expires at 2023-03-14 23:59:59 GMT
    uint256 public constant BET_EXPIRY_TIMESTAMP = 1678838399;
    // will set to 22M USDC/USDT (both have 6 decimals)
    uint256 public immutable rugThreshold;
    
    constructor() {
        rugThreshold = (22 * 1000 * 1000) * (10**USDT.decimals());
        
        protocolName = "Cobie"; // lol
        testedContracts = [ESCROW_ADDR, address(USDC), address(USDT)];
    }

    /// @notice Checks USDC + USDT balance of Do-Algod-DCR escrow wallet address
    /// @return true if escrow wallet has greater than or equal to 22M USDC+USDT
    function checkTestPasses() external view override returns (bool) {
        // only check rug during the bet period
        if (block.timestamp <= BET_EXPIRY_TIMESTAMP) {
            return (USDC.balanceOf(ESCROW_ADDR) + USDT.balanceOf(ESCROW_ADDR)) >= rugThreshold;
        }

        // if the bet period has passed the test will always return true
        return true;
    }
}