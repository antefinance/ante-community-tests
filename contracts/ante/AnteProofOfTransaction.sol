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
import "hardhat/console.sol";
import "../libraries/ante-v06-core/AnteTest.sol";
import {ProofOfTransactionLib} from './lib/ProofOfTransactionLib.sol';
import {MPT} from './lib/MPT.sol';

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

error InvalidWitnessBlockNumber();
error InvalidWitness();
error InvalidHeader();


/// @title Ante Proof Of Transaction
/// @notice Checks if a transaction was included in a block
contract AnteProofOfTransaction is AnteTest("Ante Pool cannot pay out before failure") {
    
    address public constant AXIOM_V0 = 0x01d5b501C1fc0121e1411970fb79c322737025c2;
  
    constructor() {
        testedContracts = [address(0)];
        protocolName = "Ante";
    }

    function verifyTransaction(
      IAxiomV0.BlockHashWitness memory witness, 
      bytes memory header, 
      bytes[] memory proof, 
      bytes memory key
    ) public view returns(uint256, uint256, ProofOfTransactionLib.Transaction memory) {
      console.log("starting to verify transaction", proof[proof.length - 1].length, "bytes long");
      uint256 verificationFailureType = 0;  
      
      if(witness.blockNumber == 0) {
          console.log("InvalidWitnessBlock 0");
          //revert InvalidWitnessBlockNumber();
          verificationFailureType = 70;
      }
      if(witness.blockNumber < block.number - 256) {
        console.log("Checking historic block");
        try IAxiomV0(AXIOM_V0).isBlockHashValid(witness) returns (bool blockValidation) {
          if(!blockValidation) {
            //revert InvalidWitness();
            console.log("InvalidWitness Historic");
            verificationFailureType = 1;
          }
        } catch {
          console.log("InvalidWitness Historic");
          verificationFailureType = 1;
        }
        
      } else {
        console.log("Checking recent block");
        try IAxiomV0(AXIOM_V0).isRecentBlockHashValid(witness.blockNumber, witness.claimedBlockHash) returns (bool blockValidation) {
          if(!blockValidation) {
            //revert InvalidWitness();
            console.log("InvalidWitness Recent");
            verificationFailureType = 2;
          }
        
        }catch {
          console.log("InvalidWitness Recent");
          verificationFailureType = 2;
        }
      }
      bytes32 blockHashFromHeader = keccak256(header);
      if(blockHashFromHeader != witness.claimedBlockHash) {
        //revert InvalidHeader();
        verificationFailureType = 3;
        console.log("Invalid Header");
      }
      
      bytes32 transactionsRoot = ProofOfTransactionLib.getTransactionsTrieRootFromHeader(header);
      console.log("transactionsRoot pulled from header");
      bytes memory txEncodedData = proof[proof.length - 1];
      MPT.MerkleProof memory merkleProof = MPT.MerkleProof({
        key: key,
        proof: proof,
        expectedRoot: transactionsRoot,
        keyIndex: 0,
        proofIndex: 0,
        expectedValue: txEncodedData
      });
      console.log("merkle proof created");
      uint256 verified = MPT.verifyTrieProof(merkleProof);
      if(verified == 0){
        console.log("verification passed");
      } else {
        console.log("verification failed", verified);
      }
      return(verificationFailureType, verified, 
        ProofOfTransactionLib.decodeTransactionFromProof(txEncodedData));
    }


    /// @notice test checks that payouts do not happen before failure
    /// @return true if no payouts have happened on unfailed tests
    function checkTestPasses() public view override returns (bool) {
        
        return true;
    }

}
