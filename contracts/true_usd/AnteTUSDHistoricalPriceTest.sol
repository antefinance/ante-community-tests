// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import {AnteTest} from "../libraries/ante-v06-core/AnteTest.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IAxiomV1Query} from "../interfaces/IAxiomV1Query.sol";


interface AggregatorV3InterfaceExtended is AggregatorV3Interface {
    function aggregator() external view returns (address);
}

struct HotVars {
    bytes16 latestConfigDigest;
    uint40 latestEpochAndRound;
    uint8 threshold;
    uint32 latestAggregatorRoundId;
}

struct Transmission {
    int192 answer;
    uint64 timestamp;
}


/// @title Checks that the total supply of CryptoPunks never exceeded 10,000
/// @author delalunia.eth
/// @notice Ante Test to check the the total supply of CryptoPunks has never
///         exceeded 10,000
contract AnteCryptoPunksHistoricalSupplyTest is
    AnteTest("")
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

        protocolName = "";
        testedContracts = [TRUE_USD];
    }

    function getStateTypes() external pure override returns (string memory) {
        return "bytes32,bytes32,bytes23,BlockResponse[],AccountResponse[],StorageResponse[]";
    }

    function getStateNames() external pure override returns (string memory) {
        return "keccakBlockResponse,keccakAccountResponse,keccakStorageResponse,blockResponses,accountResponses,storageResponses";
    }

    function checkTestPasses() public view override returns (bool) {
        bool validResponse = axiom_v1.areResponsesValid(
            keccakBlockResponse,
            keccakAccountResponse,
            keccakStorageResponse,
            blockResponses,
            accountResponses,
            storageResponses
        );

        if (!validResponse) {
            return true;
        }

        // roundId = s_hotVars.latestAggregatorRoundId;
        // Transmission memory transmission = s_transmission(roundId);
        // return (roundId, transmission.answer, transmission.timestamp, transmission.timestamp, roundId)
        // slot 0x2b = s_hotVars
        // slot 0x2c = s_transmissions mapping(uint32 => struct OffchainAggregator.Transmission)

        HotVars memory s_hotvars;
        Transmission[] memory s_transmissions;
        for (uint256 i = 0; i < blockResponses.length; i++) {
            if (accountResponses[i].addr == aggregator && storageResponses[i].slot == S_HOTVARS_SLOT) {
                s_hotvars = storageResponses[i].value;
            }
            if (accountResponses[i].addr == aggregator && storageResponses[i].slot == S_TRANSMISSIONS_SLOT) {
                s_transmissions = storageResponses[i].value;
            }
        }

        if (s_hotvars.latestAggregatorRoundId && s_transmissions.answer) {
            uint80 roundId = s_hotvars.latestAggregatorRoundId;
            Transmission memory transmission = s_transmissions[uint32(roundId)];
            return (90000000 < transmission.answer);
        }
        return true;
    }

    function _setState(bytes memory _state) internal override {
        (
            bytes32 keccakBlockResponse,
            bytes32 keccakAccountResponse,
            bytes32 keccakStorageResponse,
            IAxiomV1Query.BlockResponse[] calldata blockResponses,
            IAxiomV1Query.AccountResponse[] calldata accountResponse,
            IAxiomV1Query.StorageResponse[] calldata storageResponse
        ) = abi.decode(
            _state,
            (
                bytes32,
                bytes32,
                bytes32,
                IAxiomV1Query.BlockResponse[],
                IAxiomV1Query.AccountRespose[],
                IAxiomV1Query.StorageResponse[]
            )
        );
    }
}
