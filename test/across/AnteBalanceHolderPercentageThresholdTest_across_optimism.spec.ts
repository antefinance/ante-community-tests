import hre from 'hardhat';
const { waffle } = hre;

import { AnteBalanceHolderPercentageThresholdTest__factory, AnteBalanceHolderPercentageThresholdTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBalanceHolderPercentageThresholdTest Across Optimism', function () {
  let test: AnteBalanceHolderPercentageThresholdTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBalanceHolderPercentageThresholdTest',
      deployer
    )) as AnteBalanceHolderPercentageThresholdTest__factory;
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
