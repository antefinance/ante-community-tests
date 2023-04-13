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


function buffer2hex(buffer: Buffer) {
  return '0x' + buffer.toString('hex');
}

function index2key(index: number, proofLength: number) {
  const actualkey: Buffer[] = [];
  const encoded = buffer2hex(rlp.encode(index)).slice(2);
  let key = [...new Array(encoded.length / 2).keys()].map(i => parseInt(encoded[i * 2] + encoded[i * 2 + 1], 16));

  key.forEach(val => {
      if (actualkey.length + 1 === proofLength) {
          actualkey.push(val);
      } else {
          actualkey.push(val >> 4));
          actualkey.push(val % 16);
      }
  });
  return '0x' + actualkey.map(v => v.toString(16).padStart(2, '0')).join('');
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
 
  console.log("PROOF");

  console.log(proof.map((proofNode, idx) => {
    const ps = rlp.decode(proofNode);
    console.log(`P${idx} `, ps.length);
    return ps.map((p)=>p);
  }));
 
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

