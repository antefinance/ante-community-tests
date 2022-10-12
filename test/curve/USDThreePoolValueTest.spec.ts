import hre from 'hardhat';
const { waffle } = hre;

import { USDThreePoolValueTest, USDThreePoolValueTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCurveUSDThreePoolBalanceTest', function () {
  let test: USDThreePoolValueTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'USDThreePoolValueTest',
      deployer
    )) as USDThreePoolValueTest__factory;
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
