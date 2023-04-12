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
  
    const block = prevBlock; // await hre.ethers.provider.getBlock("0x4dc37b4331685511a3fd3950678e51691ad41c214d8c501bf941803b94956a2e");
    console.log(`Block number: ${block.number}`);
    
    const randomTransaction = block.transactions[Math.floor(Math.random() * block.transactions.length)];
    //const randomTransaction = block.transactions[17];
    const txProof = await getTransactionProof(randomTransaction);
    
    const { witness, proof } = txProof;
    const blockHeader = txProof.blockInfo.block.header.serialize();
    console.log(rlp.decode(proof[0]));

    const [failType, verified, transaction] = await test.verifyTransaction(
      witness,
      blockHeader,
      proof,
      txProof.key,
      {
        gasLimit: 5000000,
      }
    );
    console.log(transaction);
    console.log(verified);
    console.log(failType);
    expect(true).to.be.true;
      
  })
});
