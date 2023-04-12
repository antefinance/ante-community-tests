/// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;
import {RLPReader} from './RLPReader.sol';
import {RLPEncode} from './RLPEncode.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
library ProofOfTransactionLib {
  struct Transaction {
    uint256 txType;
    uint256 chainId;
    uint256 nonce;
    uint256 gasPrice;
    uint256 maxPriorityFeePerGas;
    uint256 maxFeePerGas;
    uint256 gasLimit;
    address to;
    uint256 value;
    bytes data;
    bytes accessList;
    uint256 v;
    uint256 r;
    uint256 s;
    bytes32 txHash;
    address from;
  }
  using RLPReader for RLPReader.RLPItem;
  
  function copyBytes(bytes memory source, uint256 start, uint256 end) internal pure returns(bytes memory) {
    if(end == 0){
      end = source.length;
    }
    bytes memory result = new bytes(end-start);
    for(uint256 i = start; i < end; i++){
      result[i-start] = source[i];
    }
    return result;
  }

  function copyBytes(bytes memory source, uint256 start) internal pure returns(bytes memory) {
    return copyBytes(source, start, source.length);
  }

  function getTransactionTypeFromProof(bytes memory proof) internal pure returns(uint256) {
    RLPReader.RLPItem[] memory proofItems = RLPReader.toRlpItem(proof).toList();
    RLPReader.RLPItem[] memory items = RLPReader.toRlpItem(proofItems[proofItems.length-1].toBytes()).toList();
    if(items.length == 2){
      // transaction with type
      bytes memory rlpEncodedTransactionBytes = items[1].toBytes();
      uint256 transactionType = uint256(uint8(rlpEncodedTransactionBytes[0]));
      return transactionType;
    }
    
    return 0;
  }

  function getTransactionUnsignedHashLegacy(Transaction memory transaction) internal pure returns(bytes32) {
    
    bytes[] memory items = new bytes[](6);
    items[0] = RLPEncode.encodeUint(transaction.nonce);
    items[1] = RLPEncode.encodeUint(transaction.gasPrice);
    items[2] = RLPEncode.encodeUint(transaction.gasLimit);
    items[3] = RLPEncode.encodeAddress(transaction.to);
    items[4] = RLPEncode.encodeUint(transaction.value);
    items[5] = RLPEncode.encodeBytes(transaction.data);
    bytes memory txSerialized = RLPEncode.encodeList(items);
    return keccak256(txSerialized);
  }

  function getTransactionUnsignedHashEIP1559(Transaction memory transaction) internal pure returns(bytes32) {
    bytes[] memory items = new bytes[](9);
    items[0] = RLPEncode.encodeUint(transaction.chainId);
    items[1] = RLPEncode.encodeUint(transaction.nonce);
    items[2] = RLPEncode.encodeUint(transaction.maxPriorityFeePerGas);
    items[3] = RLPEncode.encodeUint(transaction.maxFeePerGas);
    items[4] = RLPEncode.encodeUint(transaction.gasLimit);
    items[5] = RLPEncode.encodeAddress(transaction.to);
    items[6] = RLPEncode.encodeUint(transaction.value);
    items[7] = RLPEncode.encodeBytes(transaction.data);
    items[8] = RLPEncode.encodeBytes(transaction.accessList);
    bytes memory txSerialized = RLPEncode.encodeList(items);
    bytes[] memory enveloped = new bytes[](2);
    enveloped[0] = abi.encodePacked(transaction.txType);
    enveloped[1] = txSerialized;
    return keccak256(abi.encodePacked(enveloped[0], enveloped[1]));
  }

  function getTransactionUnsignedHashEIP2930(Transaction memory transaction) internal pure returns(bytes32) {
    bytes[] memory items = new bytes[](8);
    items[0] = RLPEncode.encodeUint(transaction.chainId);
    items[1] = RLPEncode.encodeUint(transaction.nonce);
    items[2] = RLPEncode.encodeUint(transaction.gasPrice);
    items[3] = RLPEncode.encodeUint(transaction.gasLimit);
    items[4] = RLPEncode.encodeAddress(transaction.to);
    items[5] = RLPEncode.encodeUint(transaction.value);
    items[6] = RLPEncode.encodeBytes(transaction.data);
    items[7] = RLPEncode.encodeBytes(transaction.accessList);
    bytes memory txSerialized = RLPEncode.encodeList(items);
    bytes[] memory enveloped = new bytes[](2);
    enveloped[0] = abi.encodePacked(transaction.txType);
    enveloped[1] = txSerialized;
    return keccak256(abi.encodePacked(enveloped[0], enveloped[1]));
  }

  function getTransactionUnsignedHash(Transaction memory transaction) internal pure returns(bytes32) {
    if(transaction.txType == 0){
      return getTransactionUnsignedHashLegacy(transaction);
    } else if(transaction.txType == 1){
      return getTransactionUnsignedHashEIP1559(transaction);
    } else if(transaction.txType == 2){
      return getTransactionUnsignedHashEIP2930(transaction);
    }
    return bytes32(0);
  }

  function decodeLegacyTransactionFromBytes(bytes memory transactionData) internal pure returns(Transaction memory) {
    Transaction memory transaction;
    transaction.txType = 0;
    RLPReader.RLPItem[] memory rlpTx = RLPReader.toRlpItem(transactionData).toList();
    transaction.nonce = rlpTx[0].toUint();
    transaction.gasPrice = rlpTx[1].toUint();
    transaction.gasLimit = rlpTx[2].toUint();
    transaction.to = rlpTx[3].toAddress();
    transaction.value = rlpTx[4].toUint();
    transaction.data = rlpTx[5].toBytes();
    transaction.v = rlpTx[6].toUint();
    transaction.r = rlpTx[7].toUint();
    transaction.s = rlpTx[8].toUint();
    transaction.txHash = keccak256(transactionData);

    (address from,) = ECDSA.tryRecover(getTransactionUnsignedHash(transaction), 
      uint8(transaction.v), 
      bytes32(transaction.r), 
      bytes32(transaction.s)
    );
    transaction.from = from;
    
    return transaction;
  }

  function decodeEIP1559TransactionFromBytes(bytes memory transactionData) internal pure returns(Transaction memory) {
    Transaction memory transaction;
    transaction.txType = uint256(uint8(transactionData[0]));

    RLPReader.RLPItem[] memory rlpTx = RLPReader.toRlpItem(copyBytes(transactionData, 1)).toList();
    
    transaction.chainId = rlpTx[0].toUint();
    transaction.nonce = rlpTx[1].toUint();
    transaction.maxPriorityFeePerGas = rlpTx[2].toUint();
    transaction.maxFeePerGas = rlpTx[3].toUint();
    transaction.gasLimit = rlpTx[4].toUint();
    transaction.to = rlpTx[5].toAddress();
    transaction.value = rlpTx[6].toUint();
    transaction.data = rlpTx[7].toBytes();
    transaction.accessList = rlpTx[8].toBytes();
    transaction.v = rlpTx[9].toUint();
    transaction.r = rlpTx[10].toUint();
    transaction.s = rlpTx[11].toUint();
    transaction.txHash = keccak256(transactionData);
    (address from,) = ECDSA.tryRecover(getTransactionUnsignedHash(transaction), 
      uint8(transaction.v), 
      bytes32(transaction.r), 
      bytes32(transaction.s)
    );
    transaction.from = from;
    return transaction;
  }

  function decodeEIP2930TransactionFromBytes(bytes memory transactionData) internal pure returns(Transaction memory) {
    Transaction memory transaction;
    transaction.txType = uint256(uint8(transactionData[0]));

    RLPReader.RLPItem[] memory rlpTx = RLPReader.toRlpItem(copyBytes(transactionData, 1)).toList();
    
    transaction.chainId = rlpTx[0].toUint();
    transaction.nonce = rlpTx[1].toUint();
    transaction.gasPrice = rlpTx[2].toUint();
    transaction.gasLimit = rlpTx[3].toUint();
    transaction.to = rlpTx[4].toAddress();
    transaction.value = rlpTx[5].toUint();
    transaction.data = rlpTx[6].toBytes();
    transaction.accessList = rlpTx[7].toBytes();
    transaction.v = rlpTx[8].toUint();
    transaction.r = rlpTx[9].toUint();
    transaction.s = rlpTx[10].toUint();
    transaction.txHash = keccak256(transactionData);
    (address from,) = ECDSA.tryRecover(getTransactionUnsignedHash(transaction), 
      uint8(transaction.v), 
      bytes32(transaction.r), 
      bytes32(transaction.s)
    );
    transaction.from = from;
    return transaction;
  }

  function getTransactionFromProof(bytes memory proof) internal pure returns(Transaction memory) {
    RLPReader.RLPItem[] memory proofItems = RLPReader.toRlpItem(proof).toList();
      RLPReader.RLPItem[] memory items = RLPReader.toRlpItem(proofItems[proofItems.length-1].toBytes()).toList();
      uint256 transactionType = 0;
      bytes memory rlpEncodedTransactionBytes = items[1].toBytes();
      transactionType = uint256(uint8(rlpEncodedTransactionBytes[0]));
      if(transactionType == 2) {
        return decodeEIP1559TransactionFromBytes(items[items.length-1].toBytes());
      }
      if (transactionType == 1) {
        return decodeEIP2930TransactionFromBytes(items[items.length-1].toBytes());
      }
      return decodeLegacyTransactionFromBytes(items[items.length-1].toBytes());
      
  }

}