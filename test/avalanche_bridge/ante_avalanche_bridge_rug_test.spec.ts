import hre from 'hardhat';
const { waffle } = hre;

import { AnteAvalancheBridgeRugTest__factory, AnteAvalancheBridgeRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAvalancheBridgeRugTest', function () {
  let test: AnteAvalancheBridgeRugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAvalancheBridgeRugTest',
      deployer
    )) as AnteAvalancheBridgeRugTest__factory;
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
