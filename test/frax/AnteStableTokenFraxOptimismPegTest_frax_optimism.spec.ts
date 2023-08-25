import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenFraxOptimismPegTest__factory, AnteStableTokenFraxOptimismPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenFraxOptimismPegTest', function () {
  let test: AnteStableTokenFraxOptimismPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenFraxOptimismPegTest', deployer)) as AnteStableTokenFraxOptimismPegTest__factory;
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
