import hre from 'hardhat';
const { waffle } = hre;

import { AnteRaiRedemptionTest__factory, AnteRaiRedemptionTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteRaiRedemptionTest', function () {
  let test: AnteRaiRedemptionTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteRaiRedemptionTest',
      deployer
    )) as AnteRaiRedemptionTest__factory;
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
