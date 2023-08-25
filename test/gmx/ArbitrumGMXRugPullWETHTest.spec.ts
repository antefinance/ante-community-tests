import hre from 'hardhat';
const { waffle, ethers } = hre;

import { ArbitrumGMXRugPullWETHTest, ArbitrumGMXRugPullWETHTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('ArbitrumGMXRugPullWETHTest', function () {
  if (process.env.NETWORK !== 'arbitrumOne') {
    return;
  }

  let test: ArbitrumGMXRugPullWETHTest;
  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'ArbitrumGMXRugPullWETHTest',
      deployer
    )) as ArbitrumGMXRugPullWETHTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    // test initial state
    expect(await test.checkTestPasses()).to.be.true;
  });
});
