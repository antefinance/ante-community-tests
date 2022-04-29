import hre from 'hardhat';
const { waffle } = hre;

import { AnteBalancerV2TokenBalanceTest__factory, AnteBalancerV2TokenBalanceTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBalancerV2TokenBalanceTest', function () {
  let test: AnteBalancerV2TokenBalanceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBalancerV2TokenBalanceTest',
      deployer
    )) as AnteBalancerV2TokenBalanceTest__factory;
    test = await factory.deploy(
      '0xBA12222222228d8Ba445958a75a0704d566BF2C8', // balancerV2
      '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
      '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH,
      '0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0', // wstE,
      '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // WBTC
      '0x6B175474E89094C44Da98b954EedeAC495271d0F' // DAI
    );
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
