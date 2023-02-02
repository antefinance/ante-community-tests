import hre from 'hardhat';
const { waffle } = hre;

import { AnteStargateFantomTVLPlungeTest, AnteStargateFantomTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

describe('AnteStargateFantomTVLPlungeTest', function () {
  if (process.env.NETWORK != 'fantom') return;

  let test: AnteStargateFantomTVLPlungeTest;
  let usdc: Contract;

  let globalSnapshotId: string;

  const usdcAddr = '0x04068DA6C83AFCFA0e13ba15A6696662335D5B75';
  const sgUSDCPoolAddr = '0x12edeA9cd262006cC3C4E77c90d2CD2DD4b1eb97';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4';

  let startUSDCBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteStargateFantomTVLPlungeTest',
      deployer
    )) as AnteStargateFantomTVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get balances on deploy
    usdc = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdcAddr, deployer);
    startUSDCBalance = await usdc.balanceOf(sgUSDCPoolAddr);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDC balance drops by 89%, should still pass', async () => {
    // transfer away 89.9% of pool funds
    await fundSigner(sgUSDCPoolAddr);
    await runAsSigner(sgUSDCPoolAddr, async () => {
      const sgUSDCPoolSigner = await hre.ethers.getSigner(sgUSDCPoolAddr);
      await usdc.connect(sgUSDCPoolSigner).transfer(targetAddr, startUSDCBalance.mul(9).div(10).sub(1));
    });

    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDC balance drops by 90%, should fail', async () => {
    // transfer away enough to get 90% of pool funds
    await runAsSigner(sgUSDCPoolAddr, async () => {
      const sgUSDCPoolSigner = await hre.ethers.getSigner(sgUSDCPoolAddr);
      await usdc.connect(sgUSDCPoolSigner).transfer(targetAddr, 2);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
