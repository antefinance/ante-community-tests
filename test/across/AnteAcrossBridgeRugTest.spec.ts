import hre from 'hardhat';
const { waffle } = hre;

import { AnteAcrossBridgeTest__factory, AnteAcrossBridgeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAcrossBridgeTest', function () {
  let test: AnteAcrossBridgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAcrossBridgeTest',
      deployer
    )) as AnteAcrossBridgeTest__factory;
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
