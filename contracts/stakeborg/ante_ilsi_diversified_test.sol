// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

struct Position {
    address component;
    address module;
    int256 unit;
    uint8 positionState;
    bytes data;
}

interface IILSIToken {
    function getPositions() external view returns (Position[] memory);
}

interface IOracle {
    /**
     * @return  Current price of asset represented in uint256, typically a preciseUnit where 10^18 = 1.
     */
    function read() external view returns (uint256);
}

/**
 * @title IOracleAdapter
 * @author Set Protocol
 *
 * Interface for calling an oracle adapter.
 */
interface IOracleAdapter {
    /**
     * Function for retrieving a price that requires sourcing data from outside protocols to calculate.
     *
     * @param  _assetOne    First asset in pair
     * @param  _assetTwo    Second asset in pair
     * @return                  Boolean indicating if oracle exists
     * @return              Current price of asset represented in uint256
     */
    function getPrice(address _assetOne, address _assetTwo) external view returns (bool, uint256);
}

interface IPriceOracle {
    function oracles(address assetOne, address assetTwo) external view returns (IOracle);
}

interface IUniswapV3Pool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function liquidity() external view returns (uint128);
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

/// @title  ILSI token has more than 3 tokens and none has a +50% position
/// @notice Ante Test to check that the components of ILSI are more than 3 and
/// none of the positions represent more than 50%
contract AnteILSIDiversifiedTest is AnteTest("ILSI token has more than 3 tokens and none has a +50% position") {
    address public constant QUOTE_ASSET = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC address
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH address
    address public constant ILSI_ADDRESS = 0x0acC0FEE1D86D2cD5AF372615bf59b298D50cd69;
    address public constant UNISWAP_V3_FACTORY_ADDRESS = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    IILSIToken public ilsi = IILSIToken(0x0acC0FEE1D86D2cD5AF372615bf59b298D50cd69);
    IPriceOracle public priceOracle = IPriceOracle(0xA60f9e1641747762aDE7FD5F881b90B691E92B0a);
    IUniswapV3Factory public uniswapFactory;
    FeedRegistryInterface internal registry;

    constructor() {
        // Chainlink Feed Registry mainnet
        registry = FeedRegistryInterface(0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf);
        uniswapFactory = IUniswapV3Factory(UNISWAP_V3_FACTORY_ADDRESS);

        protocolName = "ILSI";
        testedContracts = [ILSI_ADDRESS];
    }

    /// @notice Checks the number of components and each component position
    /// @return true if components count is greater than 3 and none has a +50% position
    function checkTestPasses() external view override returns (bool) {
        Position[] memory positions = ilsi.getPositions();

        // Prices are retrieved with 1e8 precision as such,
        // the computed tokenValue and maxValue will have a 1e18 * 1e8 precision
        uint256 price;
        // The maximum value (unit * underlying asset price) in USD from the set
        uint256 maxValue;
        // The total value of the token in USD
        uint256 tokenValue;

        bool priceFound;

        for (uint256 i = 0; i < positions.length; i++) {
            address component = positions[i].component;

            (priceFound, price) = _getPriceFromOracle(component);

            if (!priceFound) {
                (priceFound, price) = _getPriceFromChainlink(component);
            }

            if (!priceFound) {
                (priceFound, price) = _getPriceFromUniswap(component);
            }

            // We were unable to retrieve the price from one of the assets
            // as such we are unable to properly test the allocation
            // TODO: Prevent malicious behaviour reaching this if statement
            if (!priceFound) {
                // Maybe if price is not found, store the block number.
                // If after X blocks the price is still not found, fail the test.
                // This forces the protocol to ensure they provide an on-chain
                // way to retrive all the underlying assets values
                return positions.length > 3;
            }

            // Bring all units to the same precision
            // 18 - ILSI decimals
            uint256 allocationValue = price *
                uint256(positions[i].unit) *
                10**(18 - IERC20Metadata(component).decimals());

            if (allocationValue > maxValue) {
                maxValue = allocationValue;
            }

            tokenValue += allocationValue;
        }

        return positions.length > 3 && (maxValue * 100) / tokenValue < 50;
    }

    function _getPriceFromChainlink(address base) internal view returns (bool, uint256) {
        try registry.latestRoundData(base, Denominations.USD) returns (
            uint80, /*roundID*/
            int256 price,
            uint256, /*startedAt*/
            uint256, /*timeStamp*/
            uint80 /*answeredInRound*/
        ) {
            // Return price with 1e18 precision.
            // Chainlink denomination in USD returns prices with 8 decimals
            return (true, uint256(price));
        } catch {
            return (false, 0);
        }
    }

    /**
     * Check if oracle exists. If so return that price along with boolean indicating
     * it exists. Otherwise return boolean indicating oracle doesn't exist.
     *
     * @param _asset         Address of first asset in pair
     * @return bool             Boolean indicating if oracle exists
     * @return uint256          Price of asset pair to 18 decimal precision (if exists, otherwise 0)
     */
    function _getPriceFromOracle(address _asset) internal view returns (bool, uint256) {
        IOracle oracle = priceOracle.oracles(_asset, QUOTE_ASSET);
        bool hasOracle = address(oracle) != address(0);

        if (hasOracle) {
            // Return price with 8 decimals. The same number of decimals as the QUOTE_ASSET
            return (true, oracle.read() / 10**10);
        }

        return (false, 0);
    }

    function _getPriceFromUniswap(address _asset) internal view returns (bool, uint256) {
        IUniswapV3Pool pool = IUniswapV3Pool(uniswapFactory.getPool(_asset, WETH_ADDRESS, 3000));

        if (address(pool) == address(0)) {
            pool = IUniswapV3Pool(uniswapFactory.getPool(_asset, WETH_ADDRESS, 10000));
        }

        if (address(pool) == address(0)) {
            return (false, 0);
        }

        // A reliable pool should be liquid and have at least 50 ETH locked
        if (pool.liquidity() > 0 && IERC20(WETH_ADDRESS).balanceOf(address(pool)) < 50 * 1e18) {
            return (true, 0);
        }

        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();

        // Price calculation: https://docs.uniswap.org/sdk/guides/fetching-prices#token0price
        // Returns spot price with 1e8 precision
        // sqrtPriceX96 ** 2 * 1e8 / 2 ** 192 = price
        // We split it in 2 operations in order to keep precision and avoid overflow/undeflow
        uint256 valueInEth = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96) * 1e8) >> 192;

        (, uint256 ethPrice) = _getPriceFromChainlink(Denominations.ETH);

        uint8 decimals = IERC20Metadata(_asset).decimals();

        // Asset price in USD = value in ETH * ETH price in USD / 10 ** (value in ETH precision - USD_DECIMALS)
        // 10**(18 - decimals) - keeps precision constant accross all returned prices.
        // 18 represents the decimals of WETH
        // USD_DECIMALS = 8
        return (true, (valueInEth * ethPrice) / 1e8 / 10**(18 - decimals));
    }
}
