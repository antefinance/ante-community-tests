// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../libraries/ante-v06-core/AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISablierV2Base {
    function MAX_FEE() external view returns (uint256);
}

interface ISablierV2Comptroller {
    function protocolFees(IERC20 asset) external view returns (uint256 fee);
}

/// @title AnteSablierProtocolFeeTest
/// @notice Ante Test to check that Sablier protocol fee is always less than MAX_FEE for top 3 assets
contract AnteSablierProtocolFeeTest is AnteTest("Sablier protocol fee is always less than MAX_FEE for top 3 assets") {
    address public constant LINEAR_LOCKUP_ADDR = 0xB10daee1FCF62243aE27776D7a92D39dC8740f95;
    address public constant COMPTROLLER_ADDR = 0xC3Be6BffAeab7B297c03383B4254aa3Af2b9a5BA;

    IERC20 public constant USDC_ADDR = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant DAI_ADDR = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant WETH_ADDR = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() {
        protocolName = "Sablier";
        testedContracts = [COMPTROLLER_ADDR];
    }

    /// @return true if protocol fee for top 3 assets is less than MAX_FEE
    function checkTestPasses() public view override returns (bool) {
        uint256 maxFee = ISablierV2Base(LINEAR_LOCKUP_ADDR).MAX_FEE();

        return
            ISablierV2Comptroller(COMPTROLLER_ADDR).protocolFees((USDC_ADDR)) <= maxFee &&
            ISablierV2Comptroller(COMPTROLLER_ADDR).protocolFees(DAI_ADDR) <= maxFee &&
            ISablierV2Comptroller(COMPTROLLER_ADDR).protocolFees(WETH_ADDR) <= maxFee;
    }
}
