import hre from 'hardhat';
const { waffle, ethers } = hre;

import { MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest, MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest', function () {
  let test: MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest;

  let globalSnapshotId: string;
  let plungePercentage = 10;
  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest',
      deployer
    )) as MakerDAOUNIV2DAIUSDCMCDTVLPlungeTest__factory;
    test = await factory.deploy(plungePercentage);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    const initialTVL = await test.initialTVL();
    const thresholdTVL = await test.thresholdTVL();
    expect(initialTVL).to.be.gt(thresholdTVL);
    const thresholdPercentage = initialTVL.sub(thresholdTVL).mul(100).div(initialTVL);

    expect(thresholdPercentage).to.be.eq(plungePercentage);
    expect(await test.checkTestPasses()).to.be.true;
  });
});
