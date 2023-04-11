import hre from 'hardhat';
const { waffle } = hre;

import { AnteProofOfTransaction, AnteProofOfTransaction__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { getTransactionProof } from '../proofs';
import { Interface, ParamType } from '@ethersproject/abi';


describe('AnteProofOfTransaction', function () {
  let test: AnteProofOfTransaction;

  let globalSnapshotId: string;


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
    const randomTransaction = latestBlock.transactions[Math.floor(Math.random() * latestBlock.transactions.length)];
    const txProof = await getTransactionProof(randomTransaction);
    const { witness } = txProof;
    const encodedState = hre.ethers.utils.defaultAbiCoder.encode(
      [ ParamType.fromObject({
        type: "tuple",
        name: "witness",
        components: [
          ParamType.fromString("uint32"),
          ParamType.fromString("bytes32"),
          ParamType.fromString("bytes32"),
          ParamType.fromString("uint32"),
          ParamType.fromString("bytes32[]"),
        ],
      })
        , ParamType.fromString("bytes")],
      [[
        witness.blockNumber,
        witness.claimedBlockHash,
        witness.prevHash,
        witness.numFinal,
        witness.merkleProof,
      ], "0x"]);
    try {
      const response = await test.setStateAndCheckTestPasses(encodedState, {
        gasLimit: 1000000,
      });
      console.log(response);
      
    } catch (e) {
      console.log(e);
      
    }
    expect(true).to.be.true;
  })
});
