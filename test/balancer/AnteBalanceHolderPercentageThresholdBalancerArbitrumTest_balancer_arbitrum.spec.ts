import hre from 'hardhat';
const { waffle } = hre;

import { AnteBalanceHolderPercentageThresholdBalancerArbitrumTest__factory, AnteBalanceHolderPercentageThresholdBalancerArbitrumTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBalanceHolderPercentageThresholdBalancerArbitrumTest Balancer Arbitrum', function () {
  let test: AnteBalanceHolderPercentageThresholdBalancerArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBalanceHolderPercentageThresholdBalancerArbitrumTest',
      deployer
    )) as AnteBalanceHolderPercentageThresholdBalancerArbitrumTest__factory;
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
