import hre from 'hardhat';
const { waffle } = hre;

import { AnteSUSDPegTest, AnteSUSDPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteSUSDPegTest', function () {
  let test: AnteSUSDPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteSUSDPegTest', deployer)) as AnteSUSDPegTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('willTestWork functions as expected', async () => {
    expect(await test.willTestWork()).to.be.false;

    await test.preCheck();
    expect(await test.willTestWork()).to.be.false;

    await evmMineBlocks(300);
    expect(await test.willTestWork()).to.be.true;
  });

  it('preCheck functions as expected', async () => {
    await expect(test.preCheck()).to.be.revertedWith('Precheck can only be called every 800 blocks');
    await evmMineBlocks(501); // Combined with blocks from previous test, equals 801

    await test.preCheck();
    await evmMineBlocks(300);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});

