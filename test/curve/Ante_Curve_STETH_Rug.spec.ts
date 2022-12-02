import hre from 'hardhat';
const { waffle } = hre;

import { AnteCurveSTETHRugTest, AnteCurveSTETHRugTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCurveSTETHRugTest', function () {
  let test: AnteCurveSTETHRugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCurveSTETHRugTest',
      deployer
    )) as AnteCurveSTETHRugTest__factory;
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
