import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenUsdcOptimismPegTest__factory, AnteStableTokenUsdcOptimismPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenUsdcOptimismPegTest', function () {
  let test: AnteStableTokenUsdcOptimismPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenUsdcOptimismPegTest', deployer)) as AnteStableTokenUsdcOptimismPegTest__factory;
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
