import hre from 'hardhat';
const { waffle, ethers } = hre;

import {
  ArbitrumGMXRugPullAllWhitelistedTokensTest,
  ArbitrumGMXRugPullAllWhitelistedTokensTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('ArbitrumGMXRugPullAllWhitelistedTokensTest', function () {
  if (process.env.NETWORK !== 'arbitrumOne') {
    return;
  }

  let test: ArbitrumGMXRugPullAllWhitelistedTokensTest;
  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'ArbitrumGMXRugPullAllWhitelistedTokensTest',
      deployer
    )) as ArbitrumGMXRugPullAllWhitelistedTokensTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    // test initial state
    expect(await test.checkTestPasses()).to.be.true;

    let stateAbiEncoded = ethers.utils.defaultAbiCoder.encode(['bool'], [true]);
    await test.setStateAndCheckTestPasses(stateAbiEncoded);

    expect(await test.checkTestPasses()).to.be.true;
  });
});
