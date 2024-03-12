import hre from 'hardhat';
const { waffle } = hre;

import { AnteDaiPegTest__factory , AnteDaiPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenDaiPegTest', function () {
  let test: AnteDaiPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteDaiPegTest', deployer)) as AnteDaiPegTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
