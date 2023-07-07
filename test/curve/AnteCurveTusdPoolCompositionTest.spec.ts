import hre from 'hardhat';
const { waffle } = hre;

import { AnteCurveTusdPoolCompositionTest, AnteCurveTusdPoolCompositionTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCurveTusdPoolCompositionTest', function () {
  let test: AnteCurveTusdPoolCompositionTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCurveTusdPoolCompositionTest',
      deployer
    )) as AnteCurveTusdPoolCompositionTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    console.log('TUSD Balance = ' + await test.getTUSDBalance());
    console.log('Scaled DAI Balance = ' + await test.getScaledDAIBalance());
    console.log('Scaled USDC Balance = ' + await test.getScaledUSDCBalance());
    console.log('Scaled USDT Balance = ' + await test.getScaledUSDTBalance());
    console.log('3CRV Scaling Factor = ' + await test.get3CRVScalingFactor());
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('values (3, 89, 2, 5) should pass', async () => {
    expect(await test.isLessThanNinety(3, 89, 2, 5)).to.be.true;
  });

  it('values (2, 90, 3, 5) should fail', async () => {
    expect(await test.isLessThanNinety(2, 90, 3, 5)).to.be.false;
  });
});
