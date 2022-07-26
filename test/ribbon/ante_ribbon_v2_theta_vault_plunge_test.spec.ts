import hre from 'hardhat';
const { waffle } = hre;

import { AnteRibbonV2ThetaVaultPlungeTest__factory, AnteRibbonV2ThetaVaultPlungeTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteRibbonV2ThetaVaultPlungeTest', function () {
  let test: AnteRibbonV2ThetaVaultPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteRibbonV2ThetaVaultPlungeTest',
      deployer
    )) as AnteRibbonV2ThetaVaultPlungeTest__factory;
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
