import hre from 'hardhat';
const { waffle } = hre;

import { AnteProofOfTransaction, AnteProofOfTransaction__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { getTransactionProof } from '../proofs';


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
    
    const proofEncoded = `${fullProof.toString('hex')}`;

    console.log(txProof.tx);

    await test.testSetState({
      blockNumber: witness.blockNumber,
      claimedBlockHash: witness.claimedBlockHash,
      prevHash: witness.prevHash,
      numFinal: witness.numFinal,
      merkleProof: witness.merkleProof,
    }, fullProof, {
      gasLimit: 5000000
    });
    let i = 0;
    console.log(`${proofEncoded}`);
    const transactionType = await test.getTransactionType();
    console.log(`Transaction type: ${transactionType}`);
    while (true) {
      try {
        const rlpItem = await test.getRLPItem(i);
        console.log(i, rlpItem);
        try {
          const calledAddress = await test.getCalledAddress(i);
          console.log(calledAddress, i);
          expect(calledAddress).to.equal(txProof.tx.to);
        } catch (e) {
          console.log(`not ${i}`);
        }
      } catch (e) {
        console.log(i, e);
        break;
      }
      i += 1;
    }
    

    await test.checkTestPasses({
      gasLimit: 10000000
    });
    
    
    expect(true).to.be.true;
  }, )
});
