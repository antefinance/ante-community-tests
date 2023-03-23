import hre from 'hardhat';
const { waffle } = hre;

import { AnteBalanceHolderPercentageThresholdAcrossArbitrumTest__factory, AnteBalanceHolderPercentageThresholdAcrossArbitrumTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBalanceHolderPercentageThresholdAcrossArbitrumTest Across Arbitrum', function () {
  let test: AnteBalanceHolderPercentageThresholdAcrossArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBalanceHolderPercentageThresholdAcrossArbitrumTest',
      deployer
    )) as AnteBalanceHolderPercentageThresholdAcrossArbitrumTest__factory;
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
