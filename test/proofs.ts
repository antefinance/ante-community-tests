import { UnsignedTransaction, ethers } from 'ethers';
import hre from 'hardhat';
import rlp from 'rlp';
import {BaseTrie as Trie} from 'merkle-patricia-tree';
import {UnsignedTransaction, serialize} from '@ethersproject/transactions';
export function encode(input: any) {
  return input === '0x0'
    ? rlp.encode(Buffer.alloc(0))
    : rlp.encode(input);
}

export async function getAccountProof(address: string, blockHash?: string) {
  let block: ethers.providers.Block;
  if (blockHash) {
    block = await hre.ethers.provider.getBlock(blockHash);
  } else {
    block = await hre.ethers.provider.getBlock('latest');
  }
  const proof = await hre.ethers.provider.send('eth_getProof', [address, [], block.number]);

  return proof;
}

export async function getStorageProof(address: string, slots: string[], blockHash?: string) {
  let block: ethers.providers.Block;
  if (blockHash) {
    block = await hre.ethers.provider.getBlock(blockHash);
  } else {
    block = await hre.ethers.provider.getBlock('latest');
  }
  const proof = await hre.ethers.provider.send('eth_getProof', [address, slots, block.number]);

  return proof;
}

export type BlockTrieInfo = {
  trie: Trie;
  block: ethers.providers.Block;
}

export async  function getBlockTrie(blockHash: string): Promise<BlockTrieInfo> {
  let trie = new Trie();

  const block = await hre.ethers.provider.send('eth_getBlockByHash', [blockHash, false]);
  let failedCount = 0;
  for (let i = 0; i < block.transactions.length; i++) {
    const tx: ethers.Transaction = await hre.ethers.provider.getTransaction(block.transactions[i]);
    let siblingPath = Buffer.from(encode(i.toString(16)));
    tx.type = parseInt(`${tx.type}`, 16);
    
    if (tx.gasPrice && tx.maxFeePerGas) {
      if (tx.gasPrice.gt(tx.maxFeePerGas)) {
        tx.gasPrice = tx.maxFeePerGas;
      } else {
        tx.maxFeePerGas = tx.gasPrice;
      }
    }
    let txUnsigned: UnsignedTransaction;
    if (tx.type === 2) {
      txUnsigned = {
        chainId: tx.chainId == 0 ? 1 : tx.chainId,
        to: tx.to,
        data: tx.data,
        nonce: tx.nonce,
        gasLimit: tx.gasLimit,
        gasPrice: tx.gasPrice,
        maxFeePerGas: tx.maxFeePerGas,
        maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
        value: tx.value,
        type: tx.type,
      }
    } else {
      txUnsigned = {
        chainId: tx.chainId == 0 ? 1 : tx.chainId,
        to: tx.to,
        data: tx.data,
        nonce: tx.nonce,
        gasLimit: tx.gasLimit,
        gasPrice: tx.gasPrice,
        value: tx.value,
        type: tx.type,
      }
    }

  
    let serializedSiblingTx = Buffer.from(serialize(txUnsigned));
    await trie.put(siblingPath, serializedSiblingTx);
  }
  return {
    trie,
    block,
  };
}

export async function getTransactionProof(txHash: string) {
  const tx = await hre.ethers.provider.send('eth_getTransactionByHash', [txHash]);
  if(!tx) {
    throw new Error('Transaction not found');
  }
  const blockInfo = await getBlockTrie(tx.blockHash);
  const { trie } = blockInfo;
  let pathResult = await trie.findPath(Buffer.from(encode(tx.transactionIndex)));
  const rawProof = pathResult.stack.map((trieNode) => trieNode.serialize().toString('hex'));
  
  const merkleProof = rawProof.map((proofValue) => {
    return ethers.utils.keccak256(`0x${proofValue}`);
  })

  const witness = {
    blockNumber: tx.blockNumber,
    claimedBlockHash: tx.blockHash,
    prevHash: blockInfo.block.parentHash,
    numFinal: 0,
    merkleProof: merkleProof,
  };

  return {
    tx: tx,
    blockInfo,
    witness,
    path: pathResult,
    rawProof,
    merkleProof,
  };
}

