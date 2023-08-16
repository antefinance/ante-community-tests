// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IAxiomV1Query} from "../interfaces/IAxiomV1Query.sol";

/// @notice Extending the AggregatorV3Interface to grab the underlying aggregator address
interface AggregatorV3InterfaceExtended is AggregatorV3Interface {
    function aggregator() external view returns (address);
}

/// @notice HotVars struct grabbed from Chainlinks OffchainAggregator.sol
struct HotVars {
    bytes16 latestConfigDigest;
    uint40 latestEpochAndRound;
    uint8 threshold;
    uint32 latestAggregatorRoundId;
}

/// @notice Transmission struct grabbed from Chainlinks OffchainAggregator.sol
struct Transmission {
    int192 answer;
    uint64 timestamp;
}


/// @title Checks that the price of TUSD never dipped below 0.90 USD
/// @author delalunia.eth
/// @notice Ante Test to check the historical pegging of TUSD
contract AnteTUSDHistoricalPriceTest is
    AnteTest("TUSD has always remained above 0.90 USD")
{
    address public constant AXIOM_V1_QUERY = 0xd617ab7f787adF64C2b5B920c251ea10Cd35a952;
    address public constant TRUE_USD_PRICE_FEED = 0xec746eCF986E2927Abd291a2A1716c940100f8Ba;
    address public constant TRUE_USD = 0x0000000000085d4780B73119b644AE5ecd22b376;

    IAxiomV1Query internal axiom_v1 = IAxiomV1Query(AXIOM_V1_QUERY);
    AggregatorV3InterfaceExtended internal priceFeed;
    address internal aggregator;

    // storage slots
    uint256 public constant S_HOTVARS_SLOT = 43;
    uint256 public constant S_TRANSMISSIONS_SLOT = 44;

    // storage variables
    bytes32 public keccakBlockResponse;
    bytes32 public keccakAccountResponse;
    bytes32 public keccakStorageResponse;
    IAxiomV1Query.BlockResponse[] public blockResponses;
    IAxiomV1Query.AccountResponse[] public accountResponses;
    IAxiomV1Query.StorageResponse[] public storageResponses;

    constructor() {
        priceFeed = AggregatorV3InterfaceExtended(TRUE_USD_PRICE_FEED);
        aggregator = priceFeed.aggregator();

        protocolName = "TrueUSD";
        testedContracts = [TRUE_USD];
    }

    function getStateTypes() external pure override returns (string memory) {
        return "bytes32,bytes32,bytes23,BlockResponse[],AccountResponse[],StorageResponse[]";
    }

    function getStateNames() external pure override returns (string memory) {
        return "keccakBlockResponse,keccakAccountResponse,keccakStorageResponse,blockResponses,accountResponses,storageResponses";
    }

    function checkTestPasses() public view override returns (bool) {
        // Check if the responses are valid against the AxiomV1Query contract
        bool validResponse = axiom_v1.areResponsesValid(
            keccakBlockResponse,
            keccakAccountResponse,
            keccakStorageResponse,
            blockResponses,
            accountResponses,
            storageResponses
        );

        // If not valid, don't fail Ante Test
        if (!validResponse) {
            return true;
        }

        // Storage and data for Chainlink getting latestRoundData
        // roundId = s_hotVars.latestAggregatorRoundId;
        // Transmission memory transmission = s_transmission(roundId);
        // return (roundId, transmission.answer, transmission.timestamp, transmission.timestamp, roundId)
        // slot 0x2b = s_hotVars
        // slot 0x2c = s_transmissions mapping(uint32 => struct OffchainAggregator.Transmission)

        // Go through storage responses to make grab the corresponding values from the slot
        HotVars memory s_hotvars;
        Transmission[] memory s_transmissions;

        // Ensure that the storageResponses are a length of 2 to check values for
        if (storageResponses.length != 2) {
            revert("storageResponses doesn't have a length of 2");
        }

        // Check if the addresses and storage slots match the aggregator address and slot numbers
        if (
            storageResponses[0].addr == aggregator &&
            storageResponses[1].addr == aggregator &&
            storageResponses[0].slot == S_HOTVARS_SLOT
        ) {

            // Extract data from storageResponses and check if price holds
            bytes memory hotvars_storage_bytes = abi.encodePacked(storageResponses[0].value);
            s_hotvars = abi.decode(hotvars_storage_bytes, (HotVars));
            uint80 roundId = s_hotvars.latestAggregatorRoundId;
            
            if (bytes32(storageResponses[1].slot) == keccak256(abi.encode(roundId, S_TRANSMISSIONS_SLOT))) {
                bytes memory transmission_storage_bytes = abi.encodePacked((storageResponses[1].value));
                s_transmissions = abi.decode(transmission_storage_bytes, (Transmission[]));
                Transmission memory transmission = s_transmissions[uint32(roundId)];

                return (90000000 < transmission.answer);
            } else {
                revert("s_transmissions array at roundId slot doesn't match");
            }

        } else {
            revert("Address from account storage didn't match aggregator or storage slot doesn't match s_hotVars");
        }
    }

    function _setState(bytes memory _state) internal override {
        (
            bytes32 keccakBlockResponse,
            bytes32 keccakAccountResponse,
            bytes32 keccakStorageResponse,
            IAxiomV1Query.BlockResponse[] memory blockResponses,
            IAxiomV1Query.AccountResponse[] memory accountResponse,
            IAxiomV1Query.StorageResponse[] memory storageResponse
        ) = abi.decode(
            _state,
            (
                bytes32,
                bytes32,
                bytes32,
                IAxiomV1Query.BlockResponse[],
                IAxiomV1Query.AccountResponse[],
                IAxiomV1Query.StorageResponse[]
            )
        );
    }
}
