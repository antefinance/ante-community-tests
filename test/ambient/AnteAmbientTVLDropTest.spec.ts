import hre from 'hardhat';
const { waffle } = hre;

import { AnteAmbientTVLDropTest__factory, AnteAmbientTVLDropTest } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteAmbientTVLDropTest', function () {
  let test: AnteAmbientTVLDropTest;

  let globalSnapshotId: string;

  const dexAddr = '0xAaAaAAAaA24eEeb8d57D431224f73832bC34f688';
  const zeroAddr= '0x0000000000000000000000000000000000000000';

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAmbientTVLDropTest',
      deployer
    )) as AnteAmbientTVLDropTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if Ambient Swap Dex drops below 10%', async () => {
    const balance = (await waffle.provider.getBalance(dexAddr));
    await fundSigner(dexAddr);
    await runAsSigner(dexAddr, async() => {
      const dexSigner = await hre.ethers.getSigner(dexAddr);
      await dexSigner.sendTransaction({
        to: zeroAddr,
        value: balance.mul(95).div(100),
      });
    });
  });
});
