import hre from 'hardhat';
const { waffle } = hre;

import { AnteBenqiSAVAXPegTest, AnteBenqiSAVAXPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteBenqiSAVAXPegTest', function () {
  let test: AnteBenqiSAVAXPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBenqiSAVAXPegTest',
      deployer
    )) as AnteBenqiSAVAXPegTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('willTestWork fails if not prechecked', async () => {
    expect(await test.willTestWork()).to.be.false;

    await test.preCheck();
    expect(await test.willTestWork()).to.be.false;
  });

  it('willTestWork returns true if called after 20 blocks', async () => {
    await test.preCheck();
    expect(await test.willTestWork()).to.be.false;

    await evmMineBlocks(20);
    expect(await test.willTestWork()).to.be.true;
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
