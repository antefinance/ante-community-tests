import hre from 'hardhat';
const { waffle } = hre;

import { AnteILSIDiversifiedTest, AnteILSIDiversifiedTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteILSIDiversifiedTest', function () {
  let test: AnteILSIDiversifiedTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteILSIDiversifiedTest',
      deployer
    )) as AnteILSIDiversifiedTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('preCheck works as expected', async () => {
    expect(await test.preCheckBlock()).to.eq('0');
    expect(await test.lastCheckAllocation()).to.eq('0');
    expect(await test.lastCheckPositions()).to.eq('0');

    await test.preCheck();

    const currentBlock = await waffle.provider.getBlockNumber();
    expect(await test.preCheckBlock()).to.be.gt((currentBlock - 1).toString());
    expect(await test.lastCheckAllocation()).to.be.gt('1');
    expect(await test.lastCheckPositions()).to.be.gt('1');

    await evmMineBlocks(30);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
