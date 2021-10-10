import hre from 'hardhat';
const { waffle } = hre;

import { AnteCompoundTVLTest__factory, AnteCompoundTVLTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCompoundTVLTest', function () {
  let test: AnteCompoundTVLTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCompoundTVLTest',
      deployer
    )) as AnteCompoundTVLTest__factory;
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
