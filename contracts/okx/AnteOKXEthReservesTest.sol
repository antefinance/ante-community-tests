// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Checks that public OKX reserves on Eth Mainnet don't plunge by 99%
/// @notice Ante Test to check if publicly listed OKX wallet value falls
/// @author abitwhaleish.eth (0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4)
contract AnteOKXEthReservesTest is Ownable, AnteTest("OKX public reserves on Eth don't drop below $42M") {
    /// @notice Emitted when test owner adds a supported token
    /// @param token The address of token
    /// @param priceFeed The address of token price feed to USD
    event AnteTokenAdded(address indexed token, address priceFeed);

    /// @notice Emitted when test owner adds a reserve wallet address
    /// @param token the address of the token asset to include
    /// @param wallet the address of the wallet to check balance of
    event AnteReservesAdded(address indexed token, address wallet);

    /// @notice Emitted when test owner commits a Chainlink price feed update
    /// @param token the address of the token asset the feed is for
    /// @param oldFeed the address of the previous feed that is being replaced
    /// @param newFeed the new address of the price feed
    event AntePriceFeedPendingUpdate(address indexed token, address oldFeed, address newFeed);

    /// @notice Emitted when test owner updates a Chainlink price feed
    /// @param token the address of the token asset the feed is for
    /// @param oldFeed the address of the previous feed that is being replaced
    /// @param newFeed the new address of the price feed
    event AntePriceFeedUpdated(address indexed token, address oldFeed, address newFeed);

    /// @notice Emitted when test owner commits a failure threshold update
    /// @param oldThreshold the previous failure threshold value (USD)
    /// @param newThreshold the new failure threshold value (USD)
    event AnteThresholdPendingUpdate(uint256 oldThreshold, uint256 newThreshold);

    /// @notice Emitted when test owner updates the failure threshold value
    /// @param oldThreshold the previous failure threshold value (USD)
    /// @param newThreshold the new failure threshold value (USD)
    event AnteThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

    // list of tokens to check
    address[] public tokens;
    // map tokens to price oracle
    mapping(address => address) public priceFeeds;
    // map tokens to wallets
    mapping(address => address[]) public wallets;
    // keep track of checked combinations and wallets
    mapping(address => mapping(address => bool)) isChecked;
    mapping(address => bool) isWalletTested;

    // threshold asset balance for test to fail (will set in constructor)
    uint256 public failureThreshold;

    // Max wallets and tokens to check (to prevent unbounded gas usage)
    uint256 public constant MAX_TOKENS_CHECKED = 10;
    uint256 public constant MAX_WALLETS_PER_TOKEN = 50;

    /// @notice minimum time between test updates by owner
    uint256 public constant UPDATE_PRICEFEED_WAIT_PERIOD = 86400; // 1 day
    uint256 public constant UPDATE_FAILURE_WAIT_PERIOD = 604800; // 7 days

    // last timestamp test parameters were updated
    uint256 public lastUpdated;
    uint256 public updatePriceFeedCommitTime;
    uint256 public updateThresholdCommitTime;

    // variables to store updates to be enacted
    address public newToken;
    address public newPriceFeed;
    uint256 public newThreshold;

    constructor() {
        protocolName = "OKX";

        // Total Asset Value ~$3.9B on Ethereum according to
        // https://portfolio.nansen.ai/dashboard/okx?chain=ETHEREUM
        // as of 2022-12-23, $42M is ~1% of that and a nice number
        failureThreshold = 69_000_000;

        // Set up initial list of tokens, price feeds, and wallets to check
        setupInitialReservesList();

        lastUpdated = block.timestamp;
    }

    /// @notice checks balance of wallets against threshold
    /// @return true if balance of all theta vaults is greater than thresholds
    function checkTestPasses() external view override returns (bool) {
        (uint256 currentReserves, bool success) = getCurrentReserves();
        if (!success) return true; // if any reversion, should still pass
        return currentReserves > failureThreshold;
    }

    /// @notice view function to see current checked reserves value
    /// @return totalReserves total value of checked wallets in USD rounded down to nearest dollar
    /// @return success whether or not any potential reversions were caught
    function getCurrentReserves() public view returns (uint256 totalReserves, bool success) {
        success = true;
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; i++) {
            address tokenAddr = tokens[i];

            (uint256 price, uint256 priceDecimals) = getPriceWithChecks(priceFeeds[tokenAddr]);
            if (price == 0) return (0, false); // price check was not successful

            uint256 tokenBalance;
            address[] memory walletList = wallets[tokenAddr];
            uint256 walletsLength = walletList.length;

            if (tokenAddr == address(0)) {
                // ETH
                for (uint256 j = 0; j < walletsLength; j++) {
                    tokenBalance += walletList[j].balance;
                }
                // add ETH balance * ETH price, truncated down to nearest $
                totalReserves += (tokenBalance * price) / 10**(18 + priceDecimals);
            } else {
                // other tokens
                IERC20Metadata token = IERC20Metadata(tokenAddr);
                for (uint256 j = 0; j < walletsLength; j++) {
                    tokenBalance += token.balanceOf(walletList[j]);
                }
                // add token balance * token price, truncated down to nearest $
                totalReserves += (tokenBalance * price) / 10**(token.decimals() + priceDecimals);
            }
        }
        return (totalReserves, success);
    }

    // HELPER FUNCTIONS //

    // helper function to check valid price feed
    function getPriceWithChecks(address _priceFeed) internal view returns (uint256 price, uint256 decimals) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        try priceFeed.latestRoundData() returns (uint80, int256 answer, uint256, uint256 updatedAt, uint80) {
            if (block.timestamp > updatedAt + 86400) return (0, 0); // stale price feed if over 1 days
            if (answer <= 0) return (0, 0); // zero or negative price
            price = uint256(answer);
        } catch {
            return (0, 0);
        }

        try priceFeed.decimals() returns (uint8 _decimals) {
            return (price, _decimals);
        } catch {
            return (0, 0);
        }
    }

    // setup helper function to keep constructor readable
    function setupInitialReservesList() internal {
        // Sources:
        // https://portfolio.nansen.ai/dashboard/okx?chain=ETHEREUM
        // https://github.com/okex/proof-of-reserves (2022-11-22)
        // all token-wallet combos with >$2.5M value as of 2022-11-22
        // This gives us 99.9% coverage of listed reserves on Eth Mainnet

        // ETH
        tokens.push(address(0));
        priceFeeds[address(0)] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        wallets[address(0)] = [
            0x98EC059Dc3aDFBdd63429454aEB0c990FBA4A128, // OKX 6
            0x539C92186f7C6CC4CbF443F26eF84C595baBBcA1,
            0xbFbBFacCD1126A11b8F84C60b09859F80f3BD10F,
            0x868daB0b8E21EC0a48b726A1ccf25826c78C6d7F,
            0xf7858Da8a6617f7C6d0fF2bcAFDb6D2eeDF64840,
            0xf51cD688b8744b1bfD2FBa70D050dE85EC4fb9Fb,
            0x4b4e14a3773Ee558b6597070797fd51EB48606e5, // OKX Hot Wallet
            0x4E7b110335511F662FDBB01bf958A7844118c0D4,
            0xA7EFAe728D2936e78BDA97dc267687568dD593f3, // OKX 3
            0xCbffCB2c38ecd19468d366D392AC0c1DC7F04Bb6,
            0xBf94F0AC752C739F623C463b5210a7fb2cbb420B,
            0xc3AE71FE59f5133BA180cbBd76536a70Dec23d40,
            0xe95f6604A591F6ba33aCCB43a8a885C9c272108c,
            0x2c8FBB630289363Ac80705A1a61273f76fD5a161, // OKX 4
            0xdc3cE895714844B4775B6d06F0DaE513542cEE10
        ];

        // USDT
        address usdtAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens.push(usdtAddr);
        priceFeeds[usdtAddr] = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;
        wallets[usdtAddr] = [
            0x5041ed759Dd4aFc3a72b8192C143F72f4724081A, // OKX 7
            0x7eb6c83AB7D8D9B8618c0Ed973cbEF71d1921EF2, // OKX 20
            0x276cdBa3a39aBF9cEdBa0F1948312c0681E6D5Fd,
            0xBDa23B750dD04F792ad365B5F2a6F1d8593796f2,
            0x3D55CCb2a943d88D39dd2E62DAf767C69fD0179F,
            0x313Eb1C5e1970EB5CEEF6AEbad66b07c7338d369,
            0x68841a1806fF291314946EebD0cdA8b348E73d6D,
            0x9723b6d608D4841eB4Ab131687a5D4764eb30138,
            0x96FDC631F02207B72e5804428DeE274cF2aC0bCD,
            0x06d3a30cBb00660B85a30988D197B1c282c6dCB6,
            0x2c8FBB630289363Ac80705A1a61273f76fD5a161, // OKX 4
            0xc5451b523d5FFfe1351337a221688a62806ad91a, // OKX 10
            0xCbA38020cd7B6F51Df6AFaf507685aDd148F6ab6, // OKX 8
            0x65A0947BA5175359Bb457D3b34491eDf4cBF7997, // OKX 16
            0x6Fb624B48d9299674022a23d92515e76Ba880113, // OKX 14
            0x42436286A9c8d63AAfC2eEbBCA193064d68068f2, // OKX 11
            0x461249076B88189f8AC9418De28B365859E46BfD, // OKX 9
            0x4D19C0a5357bC48be0017095d3C871D9aFC3F21d, // OKX 17
            0x5C52cC7c96bDE8594e5B77D5b76d042CB5FaE5f2, // OKX 18
            0x69a722f0B5Da3aF02b4a205D6F0c285F4ed8F396, // OKX 12
            0xc708A1c712bA26DC618f972ad7A187F76C8596Fd, // OKX 13
            0xe9172Daf64b05B26eb18f07aC8d6D723aCB48f99, // OKX 19
            0xf59869753f41Db720127Ceb8DbB8afAF89030De4 // OKX 15
        ];

        // USDC
        address usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokens.push(usdcAddr);
        priceFeeds[usdcAddr] = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
        wallets[usdcAddr] = [
            0x7eb6c83AB7D8D9B8618c0Ed973cbEF71d1921EF2, // OKX 20
            0x5041ed759Dd4aFc3a72b8192C143F72f4724081A, // OKX 7
            0x2c8FBB630289363Ac80705A1a61273f76fD5a161 // OKX 4
        ];

        // USDK
        address usdkAddr = 0x1c48f86ae57291F7686349F12601910BD8D470bb;
        tokens.push(usdkAddr);
        priceFeeds[usdkAddr] = 0xfAC81Ea9Dd29D8E9b212acd6edBEb6dE38Cb43Af;
        wallets[usdkAddr] = [0x5041ed759Dd4aFc3a72b8192C143F72f4724081A];

        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; i++) {
            address tokenAddr = tokens[i];
            address[] memory walletList = wallets[tokenAddr];
            uint256 walletsLength = walletList.length;
            for (uint256 j = 0; j < walletsLength; j++) {
                address walletAddr = wallets[tokenAddr][j];
                isChecked[tokenAddr][walletAddr] = true;
                if (!isWalletTested[walletAddr]) {
                    isWalletTested[walletAddr] = true;
                    testedContracts.push(walletAddr);
                }
            }
        }
    }

    // ADMIN FUNCTIONS //

    /// @notice Add an new token, pricefeed, and wallet to test. Can only be called by owner
    /// @param token token address to check balance of (0x0 for ETH)
    /// @param _priceFeed address of AggregatorV3Interface USD price feed for token
    /// @param wallet wallet address to add
    function addToken(
        address token,
        address _priceFeed,
        address wallet
    ) public onlyOwner {
        require(tokens.length < MAX_TOKENS_CHECKED, "max tokens reached");
        require(wallets[token].length == 0, "token already supported, use addReserve instead!");
        // loosely check token validity
        require(IERC20Metadata(token).totalSupply() > 0, "invalid token");
        require(IERC20Metadata(token).balanceOf(wallet) > 0, "no token balance in wallet!");
        // loosely check price feed validity
        require(_priceFeed.code.length != 0, "Non-contract address!");
        (uint256 price, ) = getPriceWithChecks(_priceFeed);
        require(price > 0, "Invalid feed!");

        tokens.push(token);
        priceFeeds[token] = _priceFeed;
        wallets[token].push(wallet);
        isChecked[token][wallet] = true;
        if (!isWalletTested[wallet]) {
            isWalletTested[wallet] = true;
            testedContracts.push(wallet);
        }

        lastUpdated = block.timestamp;
        emit AnteTokenAdded(token, _priceFeed);
        emit AnteReservesAdded(token, wallet);
    }

    /// @notice Add an address to test. Can only be called by owner
    /// @param token token address to check balance of (0x0 for ETH)
    /// @param wallet wallet address to add
    function addReserve(address token, address wallet) public onlyOwner {
        require(priceFeeds[token] != address(0), "Token not added yet, use addToken");
        require(wallets[token].length < MAX_WALLETS_PER_TOKEN, "max wallets reached");
        require(!isChecked[token][wallet], "wallet already included");
        require(IERC20Metadata(token).balanceOf(wallet) > 0, "no token balance in wallet!");

        isChecked[token][wallet] = true;
        if (!isWalletTested[wallet]) {
            isWalletTested[wallet] = true;
            testedContracts.push(wallet);
        }

        wallets[token].push(wallet);
        lastUpdated = block.timestamp;
        emit AnteReservesAdded(token, wallet);
    }

    // TIME-BOUND ADMIN FUNCTIONS //
    // These require a 2-step commit/execute process to allow users time to
    // change their positions as a result of new information if desired

    // function to update a price feed?
    function commitUpdatePriceFeed(address _token, address _priceFeed) public onlyOwner {
        require(newPriceFeed == address(0), "Another update already pending!");
        require(priceFeeds[_token] != address(0), "Token not added yet, use addToken");
        require(_priceFeed.code.length != 0, "Non-contract address!");
        // loosely check price feed validity
        (uint256 price, ) = getPriceWithChecks(_priceFeed);
        require(price > 0, "Invalid feed!");

        newToken = _token;
        newPriceFeed = _priceFeed;
        updatePriceFeedCommitTime = block.timestamp;
        emit AntePriceFeedPendingUpdate(newToken, priceFeeds[newToken], newPriceFeed);
    }

    function executeUpdatePriceFeed() public {
        require(newPriceFeed != address(0), "No update pending!");
        require(
            block.timestamp > updatePriceFeedCommitTime + UPDATE_PRICEFEED_WAIT_PERIOD,
            "Need to wait 1 day between updates!"
        );

        emit AntePriceFeedUpdated(newToken, priceFeeds[newToken], newPriceFeed);
        priceFeeds[newToken] = newPriceFeed;

        newPriceFeed = address(0);
        lastUpdated = block.timestamp;
    }

    /// @notice Propose a new test failure threshold value and start waiting
    ///         period before update is made. Can only be called by owner.
    /// @param threshold new failure threshold (in USD, no decimals)
    function commitUpdateFailureThreshold(uint256 threshold) public onlyOwner {
        require(newThreshold == 0, "Another update already pending!");
        (uint256 currentReserves, bool success) = getCurrentReserves();
        require(success, "Unable to calculate reserves at the moment");
        require(currentReserves > threshold, "test would fail proposed threshold!");

        newThreshold = threshold;
        updateThresholdCommitTime = block.timestamp;
        emit AnteTestPendingUpdate(failureThreshold, newThreshold);
    }

    /// @notice Update test failure threshold after waiting period has passed.
    ///         Can be called by anyone, just costs gas
    function executeUpdateFailureThreshold() public {
        require(newThreshold > 0, "No update pending!");
        require(
            block.timestamp > updateThresholdCommitTime + UPDATE_FAILURE_WAIT_PERIOD,
            "Need to wait 7 days to adjust failure threshold!"
        );
        emit AnteTestFailureUpdated(failureThreshold, newThreshold);
        failureThreshold = newThreshold;

        newThreshold = 0;
        lastUpdated = block.timestamp;
    }
}
