import {  Transaction, ethers } from 'ethers';
import hre from 'hardhat';
import { rlp }  from 'ethereumjs-util';
//import {SecureTrie as Trie} from 'merkle-patricia-tree';
import { Trie } from '@ethereumjs/trie';
import { Block } from '@ethereumjs/block';
import { TransactionFactory } from '@ethereumjs/tx';
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
  block: any;
  blockInfo: any;
}

export async function getTransactionsTrie(blockHash: string): Promise<BlockTrieInfo> {
  const blockInfo = await hre.ethers.provider.send('eth_getBlockByHash', [blockHash, false]);
  const block: Block = await Block.fromEthersProvider(hre.ethers.provider, blockHash, {});
  await block.validateTransactionsTrie();
  const trie = block.txTrie;
  return {
    blockInfo,
    trie,
    block,
  };
}

export async function getTransactionProof(txHash: string) {
  const tx = await hre.ethers.provider.send('eth_getTransactionByHash', [txHash]);
  if(!tx) {
    throw new Error('Transaction not found');
  }
  const blockInfo = await getTransactionsTrie(tx.blockHash);
  const { trie } = blockInfo;
  let pathResult = await trie.findPath(rlp.encode(tx.transactionIndex));
  const rawProof = pathResult.stack.map((trieNode) => trieNode.serialize().toString('hex'));
  const proof = await trie.createProof(rlp.encode(tx.transactionIndex));
  const proved = await trie.verifyProof(trie.root(),
    rlp.encode(tx.transactionIndex),
    proof,
  );
  console.log(proved);
  if (!proved) {
    throw new Error('Invalid proof');
  }
    
  const txFromProof = TransactionFactory.fromSerializedData(proved);
  const merkleProof = rawProof.map((proofValue) => {
    return ethers.utils.keccak256(`0x${proofValue}`);
  });

  const witness = {
    blockNumber: tx.blockNumber,
    claimedBlockHash: tx.blockHash,
    prevHash: blockInfo.blockInfo.parentHash,
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
    proof: proof,
    txFromProof,
    key: rlp.encode(tx.transactionIndex),
  };
}

