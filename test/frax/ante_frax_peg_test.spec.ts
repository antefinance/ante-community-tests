import hre from 'hardhat';
const { waffle } = hre;

import { AnteFraxPegTest__factory, AnteFraxPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteFraxPegTest', function () {
  let test: AnteFraxPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (
      await hre.ethers.getContractFactory('AnteFraxPegTest', deployer)
    ) as AnteFraxPegTest__factory;
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
