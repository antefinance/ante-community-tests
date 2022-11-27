import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteRibbonV2UpdatableThetaVaultPlungeTest', function () {
  let test: AnteRibbonV2UpdatableThetaVaultPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteRibbonV2UpdatableThetaVaultPlungeTest',
      deployer
    )) as AnteRibbonV2UpdatableThetaVaultPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('cannot add vault if not owner', async () => {
    await fundSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
    await runAsSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77', async () => {
      const signer = await hre.ethers.getSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
      await expect(test.connect(signer).addVault('0xA1Da0580FA96129E753D736a5901C31Df5eC5edf')).to.be.reverted;
    });
  });

  it('cannot add invalid vault', async () => {
    await expect(test.addVault('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77')).to.be.reverted;
  });

  it('after adding vault, still passes', async () => {
    await test.addVault('0xA1Da0580FA96129E753D736a5901C31Df5eC5edf');
    expect(await test.checkTestPasses()).to.be.true;
  });
});
