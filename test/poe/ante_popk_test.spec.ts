import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { AntePoPKTest, AntePoPKTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { utils, Wallet } from 'ethers';

describe('AntePoPKTest', function () {
  let test: AntePoPKTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoPKTest', deployer)) as AntePoPKTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should still pass if incorrect wallet is used', async () => {
    const testWallet = new Wallet("0xa9df9fb0aa8b5e4bdf72435dd4c232b0c3083d13217b68a46e23582af2f91209");
    const messageHash = utils.solidityKeccak256(["string"], ["AntePoPKTest Demo"]);
    const messageHashBinary = utils.arrayify(messageHash);
    const signature = await testWallet.signMessage(messageHashBinary);
    await test.set(signature);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should still pass if incorrect message is signed', async () => {
    const testWallet = new Wallet("0xf9ad1bc6470713365953b2375dcbca1059e469132b968e154525653f6824200c");
    const messageHash = utils.solidityKeccak256(["string"], ["Something else"]);
    const messageHashBinary = utils.arrayify(messageHash);
    const signature = await testWallet.signMessage(messageHashBinary);
    await test.set(signature);
    expect(await test.checkTestPasses()).to.be.true;
  })

  it('should fail', async () => {
    const testWallet = new Wallet("0xf9ad1bc6470713365953b2375dcbca1059e469132b968e154525653f6824200c");
    const messageHash = utils.solidityKeccak256(["string"], ["AntePoPKTest Demo"]);
    const messageHashBinary = utils.arrayify(messageHash);
    const signature = await testWallet.signMessage(messageHashBinary);
    await test.set(signature);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
