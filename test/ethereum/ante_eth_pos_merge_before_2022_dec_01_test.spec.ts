import hre from 'hardhat';
const { waffle } = hre;

import { AnteEthPoSMergeBefore2022Dec01Test, AnteEthPoSMergeBefore2022Dec01Test__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmSetNextBlockTimestamp, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteEthPoSMergeBefore2022Dec01Test', function () {
  let test: AnteEthPoSMergeBefore2022Dec01Test;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteEthPoSMergeBefore2022Dec01Test',
      deployer
    )) as AnteEthPoSMergeBefore2022Dec01Test__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  // TODO Hardhat doesn't support setting block difficulty but this case should be tested as well
  /*
  it('if block difficulty > 2**64 in 2022, should pass', async () => {
    // hypothetical await evmSetBlockDifficulty(2**64);
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.true;
  });
  */

  it('if 2022-12-01 12:00:23 UTC and block difficulty < 2**64 and > 0, should fail', async () => {
    await evmSetNextBlockTimestamp(1669896023); // 2022-12-01 12:00:23 UTC
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
