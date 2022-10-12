import hre from 'hardhat';
const { waffle } = hre;

import { AnteAcrossOptimisticBridgeTest__factory, AnteAcrossOptimisticBridgeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAcrossOptimisticBridgeTest', function () {
  let test: AnteAcrossOptimisticBridgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAcrossOptimisticBridgeTest',
      deployer
    )) as AnteAcrossOptimisticBridgeTest__factory;
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
