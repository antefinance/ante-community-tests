import hre from 'hardhat';
const { waffle } = hre;

import { AnteStargateBSCTVLPlungeTest, AnteStargateBSCTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

describe('AnteStargateBSCTVLPlungeTest', function () {
  if (process.env.NETWORK != 'bsc') return;
  let test: AnteStargateBSCTVLPlungeTest;
  let usdt: Contract;
  let busd: Contract;

  let globalSnapshotId: string;

  const usdtAddr = '0x55d398326f99059fF775485246999027B3197955';
  const busdAddr = '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56';
  const sgUSDTPoolAddr = '0x9aA83081AA06AF7208Dcc7A4cB72C94d057D2cda';
  const sgBUSDPoolAddr = '0x98a5737749490856b401DB5Dc27F522fC314A4e1';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4';

  let startUSDTBalance: BigNumber;
  let startBUSDBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteStargateBSCTVLPlungeTest',
      deployer
    )) as AnteStargateBSCTVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get balances on deploy
    usdt = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdtAddr, deployer);
    busd = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', busdAddr, deployer);
    startUSDTBalance = await usdt.balanceOf(sgUSDTPoolAddr);
    startBUSDBalance = await busd.balanceOf(sgBUSDPoolAddr);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDT/BUSD balance drops by 89%, should still pass', async () => {
    // transfer away 89.9% of pool funds
    await fundSigner(sgUSDTPoolAddr);
    await runAsSigner(sgUSDTPoolAddr, async () => {
      const sgUSDTPoolSigner = await hre.ethers.getSigner(sgUSDTPoolAddr);
      await usdt.connect(sgUSDTPoolSigner).transfer(targetAddr, startUSDTBalance.mul(9).div(10).sub(1));
    });

    await fundSigner(sgBUSDPoolAddr);
    await runAsSigner(sgBUSDPoolAddr, async () => {
      const sgBUSDPoolSigner = await hre.ethers.getSigner(sgBUSDPoolAddr);
      await busd.connect(sgBUSDPoolSigner).transfer(targetAddr, startBUSDBalance.mul(9).div(10).sub(1));
    });

    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDT/BUSD balance drops by 90%, should fail', async () => {
    // transfer away enough to get 90% of pool funds
    await runAsSigner(sgUSDTPoolAddr, async () => {
      const sgUSDTPoolSigner = await hre.ethers.getSigner(sgUSDTPoolAddr);
      await usdt.connect(sgUSDTPoolSigner).transfer(targetAddr, 2);
    });

    await runAsSigner(sgBUSDPoolAddr, async () => {
      const sgBUSDPoolSigner = await hre.ethers.getSigner(sgBUSDPoolAddr);
      await busd.connect(sgBUSDPoolSigner).transfer(targetAddr, 2);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
