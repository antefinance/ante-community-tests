import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenTetherOptimismPegTest__factory, AnteStableTokenTetherOptimismPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenTetherOptimismPegTest', function () {
  let test: AnteStableTokenTetherOptimismPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenTetherOptimismPegTest', deployer)) as AnteStableTokenTetherOptimismPegTest__factory;
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
