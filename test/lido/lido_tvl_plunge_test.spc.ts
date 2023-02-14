import hre from 'hardhat';
const { waffle, ethers } = hre;

import { LidoTVLPlungeTest, LidoTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('LidoTVLPlungeTest', function () {
  let test: LidoTVLPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('LidoTVLPlungeTest', deployer)) as LidoTVLPlungeTest__factory;
    test = await factory.deploy(1000, 10000);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
