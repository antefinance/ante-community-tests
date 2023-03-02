import hre from 'hardhat';
const { waffle } = hre;

import { AnteTotalSupplyPlungeTest, AnteTotalSupplyPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteTotalSupplyPlungeTest AAVE Optimism', function () {
  let test: AnteTotalSupplyPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteTotalSupplyPlungeTest',
      deployer
    )) as AnteTotalSupplyPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should test 5 contracts', async () => {
    expect(await test.testedContracts(4)).to.equal('0x6ab707Aca953eDAeFBc4fD23bA73294241490620');
    await expect(test.testedContracts(5)).to.be.reverted;
  });

  it('thresholds are greater than 0', async () => {
    for (let i = 0; i < 5; i++) {
      expect(await test.thresholds(i)).to.be.gt(0);
    }
  });
});
