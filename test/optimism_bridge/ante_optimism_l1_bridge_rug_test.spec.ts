import hre from 'hardhat';
const { waffle } = hre;

import { AnteOptimismL1BridgeRugTest__factory, AnteOptimismL1BridgeRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteOptimismL1BridgeRugTest', function () {
  let test: AnteOptimismL1BridgeRugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismL1BridgeRugTest',
      deployer
    )) as AnteOptimismL1BridgeRugTest__factory;
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
