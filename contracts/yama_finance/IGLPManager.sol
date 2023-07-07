pragma solidity 0.8.18;

/// @notice The GlpManager contract in the GMX protocol
interface IGLPManager {
    function getPrice(bool maximize) external view returns (uint256);
}