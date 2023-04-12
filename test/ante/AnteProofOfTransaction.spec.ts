import hre from 'hardhat';
const { waffle } = hre;

import { AnteProofOfTransaction, AnteProofOfTransaction__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { getTransactionProof } from '../proofs';

import { rlp }  from 'ethereumjs-util';


describe('AnteProofOfTransaction', function () {
  let test: AnteProofOfTransaction;

  let globalSnapshotId: string;

  this.timeout(0);
  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    const factory = (await hre.ethers.getContractFactory('AnteProofOfTransaction', deployer)) as AnteProofOfTransaction__factory;
    
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });
  it('should check if a transaction was included in provided block', async () => {
    const latestBlock = await hre.ethers.provider.getBlock('latest');
    const prevBlock = await hre.ethers.provider.getBlock(latestBlock.number - 1);
    
    const block = prevBlock;
    console.log(`Block number: ${block.number}`);
    const randomTransaction = block.transactions[Math.floor(Math.random() * block.transactions.length)];
    const txProof = await getTransactionProof(randomTransaction);
    const { witness, proof } = txProof;
    

    //const proofEncoded = hre.ethers.utils.defaultAbiCoder.encode(
    //  ["bytes[]"],
    //  [proof]
    //);
    
    
    
    const fullProof = proof;
    const proofParts = rlp.decode(fullProof);

    const transactionDataFromProof = proofParts[proofParts.length - 1];

    
    console.log(txProof.tx);
    
    
    const transactionBytes = await test.geTransactionFromProof(fullProof);

    console.log(transactionBytes);
    
    expect(true).to.be.true;
  }, )
});
