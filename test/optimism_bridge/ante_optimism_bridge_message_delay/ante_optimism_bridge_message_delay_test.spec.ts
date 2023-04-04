import hre from 'hardhat';
const { waffle } = hre;

import { AnteOptimismMessageDelayTest__factory, AnteOptimismMessageDelayTest } from '../../../typechain';

import { evmSnapshot, evmRevert } from '../../helpers';
import { expect } from 'chai';

describe('AnteOptimismMessageDelayTest', function () {
  let test: AnteOptimismMessageDelayTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismMessageDelayTest',
      deployer
    )) as AnteOptimismMessageDelayTest__factory;
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
