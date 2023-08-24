// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../AnteTest.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface ICollateralOracle {
    /**
     * @notice Get collateral value
     * @param collateralToken Collateral token contract
     * @param collateralTokenId Collateral token ID
     * @return Collateral value
     */
    function collateralValue(address collateralToken, uint256 collateralTokenId) external view returns (uint256);
}

// @title MetaStreet keeps BAYC value within 25% of NFT floor price
// @notice Ante Test to check if a MetaStreet keeps collateral value of BAYC
// within -25% - +25% of the NFT floor price fetched from Chainlink
contract AnteMetaStreetCollateralValueTest is AnteTest("MetaStreet keeps BAYC value within 25% of NFT floor price") {
    // https://etherscan.io/address/0xDcbF755eb1f04EAf1aD0aBe07a7A418A85CB5783
    address private staticCollateralOracleAddr = 0xDcbF755eb1f04EAf1aD0aBe07a7A418A85CB5783;
    ICollateralOracle public staticCollateralOracle = ICollateralOracle(0xDcbF755eb1f04EAf1aD0aBe07a7A418A85CB5783);

    // https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    address public baycAddr = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    // BAYC - ETH
    AggregatorV3Interface internal nftFloorPriceFeed =
        AggregatorV3Interface(0x352f2Bc3039429fC2fe62004a1575aE74001CfcE);

    constructor() {
        protocolName = "MetaStreet";
        testedContracts.push(staticCollateralOracleAddr);
    }

    // @notice Check if MetaStreet collateral value is between -25% - +25% of floor price
    // @return true if the collateral value greater than price - 25% and less than price + 25%
    function checkTestPasses() public view override returns (bool) {
        (, int nftFloorPrice, , , ) = nftFloorPriceFeed.latestRoundData();

        // Collateral value doesn't care about token ID so we just pass 1
        uint256 collateralValue = staticCollateralOracle.collateralValue(baycAddr, 1);

        return
            uint256(nftFloorPrice - nftFloorPrice / 4) < collateralValue &&
            collateralValue < uint256(nftFloorPrice + nftFloorPrice / 4);
    }
}
