import hre from 'hardhat';
const { waffle } = hre;

import { AnteDaiCompoundcDaiAbove100MTest, AnteDaiCompoundcDaiAbove100MTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteDaiCompoundcDaiAbove100MTest', function () {
  let test: AnteDaiCompoundcDaiAbove100MTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteDaiCompoundcDaiAbove100MTest',
      deployer
    )) as AnteDaiCompoundcDaiAbove100MTest__factory;
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
