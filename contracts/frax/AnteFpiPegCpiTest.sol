// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";

interface IFPIControllerPool {
    function pegStatusMntRdm()
        external
        view
        returns (
            uint256,
            uint256,
            bool
        );

    function peg_band_mint_redeem() external view returns (uint256);
}

/// @title  FPI price remains within expected range of CPI Peg
/// @notice Ante Test to check that the price of FPI doesn't deviate from the expected range of the CPI Peg Price, but not more than 5%
contract AnteFpiPegCpiTest is AnteTest("FPI price remains within the expected range of CPI Peg, but not more than 5%") {
    address public constant FPI_CONTROLLER_ADDRESS = 0x2397321b301B80A1C0911d6f9ED4b6033d43cF51;
    address public constant FPI_TOKEN_ADDRESS = 0x5Ca135cB8527d76e932f34B5145575F9d8cbE08E;

    IFPIControllerPool private fpiController = IFPIControllerPool(FPI_CONTROLLER_ADDRESS);

    constructor() {
        testedContracts = [FPI_CONTROLLER_ADDRESS, FPI_TOKEN_ADDRESS];
        protocolName = "FRAX Finance";
    }

    /// @return true if the price is within the expected range
    function checkTestPasses() public view override returns (bool) {
        (, , bool withinRange) = fpiController.pegStatusMntRdm();
        uint256 pegBand = fpiController.peg_band_mint_redeem();

        return withinRange && pegBand <= 50000;
    }
}
