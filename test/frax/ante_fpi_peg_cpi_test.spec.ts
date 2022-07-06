import hre from 'hardhat';
const { waffle } = hre;

import { AnteFpiPegCpiTest__factory, AnteFpiPegCpiTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteFpiPegCpiTest', function () {
  let test: AnteFpiPegCpiTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteFpiPegCpiTest', deployer)) as AnteFpiPegCpiTest__factory;
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
