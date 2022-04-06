import hre from 'hardhat';
const { waffle } = hre;

import { AnteRibbonV2ThetaVaultPlungeTest2__factory, AnteRibbonV2ThetaVaultPlungeTest2 } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteRibbonV2ThetaVaultPlungeTest2', function () {
  let test: AnteRibbonV2ThetaVaultPlungeTest2;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteRibbonV2ThetaVaultPlungeTest2',
      deployer
    )) as AnteRibbonV2ThetaVaultPlungeTest2__factory;
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
