import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenDaiPegTest__factory, AnteStableTokenDaiPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenDaiPegTest', function () {
  let test: AnteStableTokenDaiPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenDaiPegTest', deployer)) as AnteStableTokenDaiPegTest__factory;
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
