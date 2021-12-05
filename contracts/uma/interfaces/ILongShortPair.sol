pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILongShortPair {

  //bool public receivedSettlementPrice;
  function receivedSettlementPrice() external view returns (bool);

  //bool public enableEarlyExpiration; // If set, the LSP contract can request to be settled early by calling the OO.
  function enableEarlyExpiration() external view returns (bool);
  //uint64 public expirationTimestamp;
  function expirationTimestamp() external view returns (uint64);
  //uint64 public earlyExpirationTimestamp; // Set in the case the contract is expired early.
  function earlyExpirationTimestamp() external view returns (uint64);
  //string public pairName;
  function pairName() external view returns (string memory);
  //uint256 public collateralPerPair; // Amount of collateral a pair of tokens is always redeemable for.
  function collateralPerPair() external view returns (uint256);

  // Number between 0 and 1e18 to allocate collateral between long & short tokens at redemption. 0 entitles each short
  // to collateralPerPair and each long to 0. 1e18 makes each long worth collateralPerPair and short 0.
  //uint256 public expiryPercentLong;
  function expiryPercentLong() external view returns (uint256);
  //bytes32 public priceIdentifier;
  function priceIdentifier() external view returns (bytes32);

  // Price returned from the Optimistic oracle at settlement time.
  //int256 public expiryPrice;
  function expiryPrice() external view returns (int256);

  // External contract interfaces.
  //IERC20 public collateralToken;
  function collateralToken() external view returns (IERC20);
  ExpandedIERC20 public longToken;
  ExpandedIERC20 public shortToken;
  FinderInterface public finder;
  LongShortPairFinancialProductLibrary public financialProductLibrary;

  // Optimistic oracle customization parameters.
  //bytes public customAncillaryData;
  function customAncillaryData() external view returns (bytes);
  //uint256 public proposerReward;
  function proposerReward() external view returns (uint256);
  //uint256 public optimisticOracleLivenessTime;
  function optimisticOracleLivenessTime() external view returns (uint256);
  //uint256 public optimisticOracleProposerBond;
  function optimisticOracleProposerBond() external view returns (uint256);

  event TokensCreated(address indexed sponsor, uint256 indexed collateralUsed, uint256 indexed tokensMinted);
  event TokensRedeemed(address indexed sponsor, uint256 indexed collateralReturned, uint256 indexed tokensRedeemed);
  event ContractExpired(address indexed caller);
  event EarlyExpirationRequested(address indexed caller, uint64 earlyExpirationTimeStamp);
  event PositionSettled(address indexed sponsor, uint256 collateralReturned, uint256 longTokens, uint256 shortTokens);

  function redeem(uint256 tokensToRedeem) external returns (uint256 collateralReturned);
  function settle(uint256 longTokensToRedeem, uint256 shortTokensToRedeem);

}