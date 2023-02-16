import hre from 'hardhat';
const { waffle, ethers } = hre;

import { MakerDAOBATMCDTVLPlungeTest, MakerDAOBATMCDTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('MakerDAOBATMCDTVLPlungeTest', function () {
  let test: MakerDAOBATMCDTVLPlungeTest;

  let globalSnapshotId: string;
  let plungePercentage = 10;
  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'MakerDAOBATMCDTVLPlungeTest',
      deployer
    )) as MakerDAOBATMCDTVLPlungeTest__factory;
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
    /*
    console.log(`
      Initial TVL: ${ethers.utils.formatUnits(initialTVL, 8)} 
      Threshold TVL: ${ethers.utils.formatUnits(thresholdTVL, 8)}
      Threshold Percentage: ${thresholdPercentage}%
    
    `);
*/
    expect(thresholdPercentage).to.be.eq(plungePercentage);
    expect(await test.checkTestPasses()).to.be.true;
  });
});
