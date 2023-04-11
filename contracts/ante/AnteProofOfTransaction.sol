// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import "../libraries/ante-v06-core/AnteTest.sol";

interface IAxiomV0 {
  function historicalRoots(uint32 startBlockNumber) external view returns (bytes32);
  event UpdateEvent(uint32 startBlockNumber, bytes32 prevHash, bytes32 root, uint32 numFinal);
  struct BlockHashWitness {
      uint32 blockNumber;
      bytes32 claimedBlockHash;
      bytes32 prevHash;
      uint32 numFinal;
      bytes32[] merkleProof;
  }
  function getEmptyHash(uint256 depth) external pure returns (bytes32);
  function isRecentBlockHashValid(uint32 blockNumber, bytes32 claimedBlockHash) external view returns (bool);
  function isBlockHashValid(BlockHashWitness calldata witness) external view returns (bool);
}


/// @title Ante Proof Of Transaction
/// @notice Checks if a transaction was included in a block
contract AnteProofOfTransaction is AnteTest("Ante Pool cannot pay out before failure") {
    address public constant AXIOM_V0 = 0x01d5b501C1fc0121e1411970fb79c322737025c2;
    address public constant AXIOM_VERIFIER = 0xf0E3B9aAdA6D89DdEb34aaB7E9cd1744CF90D82f;
    address public constant AXIOM_HISTORICAL_VERIFIER = 0xBF2c05D0362a640629b9b98Be4c4E4f9a8E22841;
    IAxiomV0.BlockHashWitness public witness;
    bytes public header;

    constructor() {
        testedContracts = [address(0)];
        protocolName = "Ante";
    }
    function getStateTypes() external pure override returns(string memory) {
      return "IAxiomV0.BlockHashWitness,bytes";
    }

    function getStateNames() external pure override returns(string memory) {
      return "witness,header";
    }

    function testSetState(IAxiomV0.BlockHashWitness memory _witness, bytes memory _header) public {
      witness = _witness;
      header = _header;

      if(witness.blockNumber < block.number - 256) {
        require(IAxiomV0(AXIOM_V0).isBlockHashValid(witness), 
        "Ante: Witness is invalid");

          (bool success, bytes memory rsp) = AXIOM_VERIFIER.staticcall(header);
          require(success, abi.decode(rsp, (string)));
      } else {
        require(IAxiomV0(AXIOM_V0).isRecentBlockHashValid(witness.blockNumber, witness.claimedBlockHash), 
        "Ante: Witness is invalid - recent");
        
        (bool success, bytes memory rsp) = AXIOM_HISTORICAL_VERIFIER.staticcall(header);
        require(success, abi.decode(rsp, (string)));
      
      }

      
    }

    /// @notice test checks that payouts do not happen before failure
    /// @return true if no payouts have happened on unfailed tests
    function checkTestPasses() public view override returns (bool) {
        if(witness.blockNumber == 0) {
            return true;
        }
        if(witness.blockNumber < block.number - 256) {
            require(IAxiomV0(AXIOM_V0).isBlockHashValid(witness), 
            "Ante: Witness is invalid");

        } else {
            require(IAxiomV0(AXIOM_V0).isRecentBlockHashValid(witness.blockNumber, witness.claimedBlockHash), 
            "Ante: Witness is invalid - recent");
        
        }

        return true;
    }

    function _setState(bytes memory _state) internal override {
        (witness, header) = abi.decode(_state, (IAxiomV0.BlockHashWitness, bytes));
        
    }
}
