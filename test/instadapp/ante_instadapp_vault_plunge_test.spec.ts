import hre from 'hardhat';
const { waffle } = hre;

import { AnteInstadappVaultPlungeTest__factory, AnteInstadappVaultPlungeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBlastETHYieldManagerPlungeTest', function () {
  let test: AnteInstadappVaultPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteInstadappVaultPlungeTest',
      deployer,
    )) as AnteInstadappVaultPlungeTest__factory;
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
