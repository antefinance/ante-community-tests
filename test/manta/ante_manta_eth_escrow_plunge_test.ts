import hre from 'hardhat';
const { waffle } = hre;

import { AnteMantaETHEscrowPlungeTest__factory, AnteMantaETHEscrowPlungeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBlastETHYieldManagerPlungeTest', function () {
  let test: AnteMantaETHEscrowPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBlastETHYieldManagerPlungeTest',
      deployer,
    )) as AnteMantaETHEscrowPlungeTest__factory;
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
