// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;

import "../AnteTest.sol";
import "./libraries/MathLib.sol";
import "@openzeppelin-contracts-old/contracts/token/ERC20/ERC20.sol";

/// @title Ante Test to check USDT supply has never exceeded M2 (as of Aug 2022) on GOERLI ONLY
/// @dev As of 2022-08-18, est. M2 monetary supply is ~$21.645 Trillion USD
/// From https://www.federalreserve.gov/releases/h6/current/default.htm
/// We represent the threshold as 21.645 Trillion * (10 ** USDT Decimals)
/// Or, more simply, 21.645 Trillion = 21,645 Billion
///
/// Q: How does this ZK Ante Test work?
/// A: Smart Contracts that run on EVM have a natural limitation that they cannot look
/// backward (in history) beyond a small number of blocks to inspect historic values.
/// Thus, most mainnet Ethereum Ante Tests need to be verified at a block height where
/// a given test is failing -- this can cause Ante to over look "past" failures (even momentarily)
/// because there is no easy way to access historical data within a smart contract.
///
/// However, zkAttestor changes this: anyone can instead generate a zkSNARK that attests
/// that a particular storage slot held a specific value at a specific block height.
/// This is done with the zkAttestor tool, which stores a zkSNARK proof that can be checked on-chain.
/// Thus, instead of checking if the guarantee holds in the current block, this zk Ante Test can
/// show if a guarantee has EVER been false in the past.
///
/// Q: How does one use this zk Ante Test?
///
/// The verifier first does research on historical data for the block height at which the test failed.
/// The output of the research is a tuple.
/// The verifier then needs to use zkAttestor to generate a zkSNARK proof (that is stored),
/// which is a claim that at a certain block height, the value of a storage slot of a certain address
/// was indeed VALUE, along with an index. This test checks that said VALUE would mean the
/// zk Ante Test fails (eg USDT supply was above M2), and that said zkSNARK lives at the index stored on
/// zkAttestor. (The zk Ante Test reverts if the claim is unverified.)
///
/// If the claim is valid (ie zkAttestor holds a proof that the value at that slot at that height),
/// then the zk Ante Test's checkTestPasses function will return False, which is an Ante Test failure.
interface IZKAttestor {
    event SlotAttestationEvent(uint32 blockNumber, address addr, uint256 slot, uint256 slotValue);

    function slotAttestations(uint256 i) external view returns (bytes32);
}

/// @notice Ante Test to check that the total USDT Goerli supply has never exceeded M2
contract AnteZKGoerliTetherTotalSupplyTest is AnteTest("Goerli Tether Total Historic Supply Test under M2") {
    using SafeMath for uint256;
    using Math for uint256;

    address public immutable goerliZkaAddr;
    address public immutable goerliUSDTAddr;
    uint256 public immutable thresholdSupply;

    uint32 public immutable storageSlotTotalSupply;

    ERC20 public goerliUSDTToken;

    uint256 public claimIdx;
    uint32 public claimBlockNumber;
    uint256 public claimTotalSupply;

    constructor() {
        protocolName = "Tether";

        address tempGoerliUSDTAddr = 0x509Ee0d083DdF8AC028f2a56731412edD63223B9;
        goerliZkaAddr = 0x4136cF04D70216b6F2B86D755F49B95E11Fe93cB;
        goerliUSDTAddr = tempGoerliUSDTAddr;
        goerliUSDTToken = ERC20(tempGoerliUSDTAddr);

        // storage slot for USDT total supply
        storageSlotTotalSupply = 1;
        claimTotalSupply = 0;

        thresholdSupply = 21645 * (1000 * 1000 * 1000) * (10**goerliUSDTToken.decimals());

        testedContracts.push(tempGoerliUSDTAddr);
    }

    function checkTestPasses() public view override returns (bool) {
        if (claimTotalSupply <= thresholdSupply) {
            return true;
        }
        bytes32 claimHash = IZKAttestor(goerliZkaAddr).slotAttestations(claimIdx);
        require(
            claimHash ==
                keccak256(abi.encodePacked(claimBlockNumber, goerliUSDTAddr, storageSlotTotalSupply, claimTotalSupply)),
            "Invalid claim hash"
        );

        return (claimTotalSupply <= thresholdSupply);
    }

    function setClaim(
        uint256 _claimIdx,
        uint32 _claimBlockNumber,
        uint256 _claimTotalSupply
    ) external {
        claimIdx = _claimIdx;
        claimBlockNumber = _claimBlockNumber;
        claimTotalSupply = _claimTotalSupply;
    }
}
