import hre from 'hardhat';
const { waffle } = hre;

import { StargateYieldFarmDifference, StargateYieldFarmDifference__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('StargateYieldFarmDifferenceTest', function () {
  let test: StargateYieldFarmDifference;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'StargateYieldFarmDifference',
      deployer
    )) as StargateYieldFarmDifference__factory;
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
