import hre from 'hardhat';
const { waffle, ethers } = hre;

import { MakerDAOTVLPlungeTest, MakerDAOTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('MakerDAOTVLPlungeTest', function () {
  let test: MakerDAOTVLPlungeTest;

  let globalSnapshotId: string;
  let plungePercentage = 10;
  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'MakerDAOTVLPlungeTest',
      deployer
    )) as MakerDAOTVLPlungeTest__factory;
    test = await factory.deploy(plungePercentage, { gasLimit: 8000000 });
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
    const univ2value = await test.getUniv2McdJoinsValue();
    const guniv3value = await test.getGuniv3McdJoinsValue();
    console.log(`
      Initial TVL: ${ethers.utils.formatUnits(initialTVL, 8)} 
      Threshold TVL: ${ethers.utils.formatUnits(thresholdTVL, 8)}
      Threshold Percentage: ${thresholdPercentage}%
      Uniswap V2 MCD Join Value: ${ethers.utils.formatUnits(univ2value, 8)}
      Gelato Uniswap V3 MCD Join Value: ${ethers.utils.formatUnits(guniv3value, 8)}
    `);
    */
    expect(thresholdPercentage).to.be.eq(plungePercentage);
    expect(await test.checkTestPasses()).to.be.true;
  });
});
