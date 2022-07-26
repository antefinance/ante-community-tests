import hre from 'hardhat';
const { waffle } = hre;

import { AnteAllbridgePlungeTest__factory, AnteAllbridgePlungeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAllbridgePlungeTest', function () {
  let test: AnteAllbridgePlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAllbridgePlungeTest',
      deployer
    )) as AnteAllbridgePlungeTest__factory;
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
