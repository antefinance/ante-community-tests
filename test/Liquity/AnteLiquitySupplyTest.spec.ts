import hre from 'hardhat';
const { waffle } = hre;

import { AnteLiquitySupplyTest, AnteLiquitySupplyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

describe('AnteLiquitySupplyTest', function () {
  let test: AnteLiquitySupplyTest;

  let globalSnapshotId: string;

  const poolAddr = '0xDf9Eb223bAFBE5c5271415C75aeCD68C21fE3D7F';
  const zeroAddr = '0x0000000000000000000000000000000000000000';

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteLiquitySupplyTest',
      deployer
    )) as AnteLiquitySupplyTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('will fail if ETH balance drops', async() => {
    const balance = (await waffle.provider.getBalance(poolAddr));
    console.log("Balance", balance);
    await fundSigner(poolAddr);
    await runAsSigner(poolAddr, async() => {
      const poolSigner = await hre.ethers.getSigner(poolAddr);
      await poolSigner.sendTransaction({
        to: zeroAddr,
        value: balance,
      });
    });
  });
});
