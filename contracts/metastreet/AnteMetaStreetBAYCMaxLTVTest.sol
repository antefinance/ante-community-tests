// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";

interface ILoanPriceOracle {
    /**
     * @notice Get collateral parameters for token contract
     * @param collateralToken Collateral token contract
     * @return Collateral parameters
     */
    function getCollateralParameters(
        address collateralToken
    ) external view returns (MetaStreet.CollateralParameters memory);
}

library MetaStreet {
    /**
     * @notice Piecewise linear model parameters
     * @param offset Output value offset in UD4x18
     * @param slope1 Slope before kink in UD4x18
     * @param slope2 Slope after kink in UD4x18
     * @param target Input value of kink in UD11x18
     * @param max Max input value in UD11x18
     */
    struct PiecewiseLinearModel {
        uint72 offset;
        uint72 slope1;
        uint72 slope2;
        uint96 target;
        uint96 max;
    }

    /**
     * @notice Collateral parameters
     * @param active Collateral is supported
     * @param loanToValueRateComponent Rate component model for loan to value
     * @param durationRateComponent Rate component model for duration
     * @param rateComponentWeights Weights for rate components, each 0 to 10000
     */
    struct CollateralParameters {
        bool active;
        PiecewiseLinearModel loanToValueRateComponent;
        PiecewiseLinearModel durationRateComponent;
        uint16[3] rateComponentWeights /* 0-10000 */;
    }
}

// @title MetaStreet doesn't set a high maximum LTV
// @notice Ante Test to check if a MetaStreet keeps the maximum LTV (loan to value) under 100%
contract AnteMetaStreetBAYCMaxLTVTest is AnteTest("MetaStreet keeps maximum LTV under 100%") {
    address private loanPriceOracleAddr = 0xCDe04b3f75616b2333FC2D51c0CcE6Ae89329A71;
    ILoanPriceOracle public loanPriceOracle = ILoanPriceOracle(0xCDe04b3f75616b2333FC2D51c0CcE6Ae89329A71);
    // https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    address public baycAddr = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    constructor() {
        protocolName = "MetaStreet";
        testedContracts.push(loanPriceOracleAddr);
    }

    // @notice Check if a MetaStreet keeps LTV below 100%
    // @return true if the maximum LTV is less than 100%
    function checkTestPasses() public view override returns (bool) {
        MetaStreet.CollateralParameters memory collateralParameters = loanPriceOracle.getCollateralParameters(baycAddr);

        return collateralParameters.loanToValueRateComponent.max <= 10 ** 18;
    }
}
