import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';
import { Address } from 'cluster';

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

  it('should pass on deploy', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('cannot add vault if not owner', async () => {
    await fundSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
    await runAsSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77', async () => {
      const signer = await hre.ethers.getSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
      await expect(
        test
          .connect(signer)
          .addVault('0xA1Da0580FA96129E753D736a5901C31Df5eC5edf', ['0xae78736Cd615f374D3085123A210448E74Fc6393'])
      ).to.be.reverted;
    });
  });

  it('cannot add invalid vault', async () => {
    await expect(
      test.addVault('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77', ['0xae78736Cd615f374D3085123A210448E74Fc6393'])
    ).to.be.reverted;
  });

  it('after adding vault, still passes', async () => {
    await test.addVault('0xA1Da0580FA96129E753D736a5901C31Df5eC5edf', ['0xae78736Cd615f374D3085123A210448E74Fc6393']);
    expect(await test.checkTestPasses()).to.be.true;
  });

  // TODO can transfer ownership?

  it('cannot execute update if none pending', async () => {
    await expect(test.executeUpdateFailureThreshold()).to.be.reverted;
  });

  it('non-owner cannot commit failure threshold update', async () => {
    await fundSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
    await runAsSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77', async () => {
      const signer = await hre.ethers.getSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
      await expect(test.connect(signer).commitUpdateFailureThreshold('0x53773E034d9784153471813dacAFF53dBBB78E8c', 0))
        .to.be.reverted;
    });
  });

  it('cannot commit update if new threshold would fail', async () => {
    await expect(
      test.commitUpdateFailureThreshold(
        '0x53773E034d9784153471813dacAFF53dBBB78E8c',
        BigNumber.from('10000000000000000000000000000')
      )
    ).to.be.reverted;
  });

  it('cannot execute update before waiting period over', async () => {
    await test.commitUpdateFailureThreshold(
      '0x53773E034d9784153471813dacAFF53dBBB78E8c',
      BigNumber.from('1000000000000000000000')
    );
    evmIncreaseTime(86400);
    evmMineBlocks(1);
    await expect(test.executeUpdateFailureThreshold()).to.be.reverted;
  });

  it('cannot commit another update during waiting period', async () => {
    await expect(
      test.commitUpdateFailureThreshold(
        '0x53773E034d9784153471813dacAFF53dBBB78E8c',
        BigNumber.from('2000000000000000000000')
      )
    ).to.be.reverted;
  });

  it('non-owner can execute update after waiting period', async () => {
    evmIncreaseTime(86400);
    evmMineBlocks(1);
    await fundSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
    await runAsSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77', async () => {
      const signer = await hre.ethers.getSigner('0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77');
      await expect(test.connect(signer).executeUpdateFailureThreshold()).not.reverted;
    });
  });

  it('test still passes after threshold update', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
