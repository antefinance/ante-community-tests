import hre from 'hardhat';
const { waffle } = hre;

import { AnteCurveThreePoolDistributionTest, AnteCurveThreePoolDistributionTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCurveThreePoolDistributionTest', function () {
  let test: AnteCurveThreePoolDistributionTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCurveThreePoolDistributionTest',
      deployer
    )) as AnteCurveThreePoolDistributionTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('values (89, 5, 6) should pass', async () => {
    expect(await test.isLessThanNinety(89, 5, 6)).to.be.true;
  });

  it('values (90, 5, 5) should fail', async () => {
    expect(await test.isLessThanNinety(90, 5, 5)).to.be.false;
  });
});
