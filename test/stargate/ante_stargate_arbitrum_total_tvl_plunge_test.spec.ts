import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteStargateArbitrumTotalTVLPlungeTest,
  AnteStargateArbitrumTotalTVLPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteStargateArbitrumTotalTVLPlungeTest', function () {
  if (process.env.NETWORK != 'arbitrum') return;

  let test: AnteStargateArbitrumTotalTVLPlungeTest;
  let usdt: Contract;
  let usdc: Contract;
  let sgeth: Contract;

  let globalSnapshotId: string;

  const usdtAddr = '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9';
  const usdcAddr = '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8';
  const sgethAddr = '0x82CbeCF39bEe528B5476FE6d1550af59a9dB6Fc0';

  const sgUSDTPoolAddr = '0xB6CfcF89a7B22988bfC96632aC2A9D6daB60d641';
  const sgUSDCPoolAddr = '0x892785f33CdeE22A30AEF750F285E18c18040c3e';
  const sgETHPoolAddr = '0x915A55e36A01285A14f05dE6e81ED9cE89772f8e';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4'; // throwaway

  let startUSDTBalance: BigNumber;
  let startUSDCBalance: BigNumber;
  let startSGETHBalance: BigNumber;
  let tvlThreshold: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteStargateArbitrumTotalTVLPlungeTest',
      deployer
    )) as AnteStargateArbitrumTotalTVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get balances on deploy
    usdt = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdtAddr, deployer);
    usdc = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdcAddr, deployer);
    sgeth = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', sgethAddr, deployer);
    startUSDTBalance = await usdt.balanceOf(sgUSDTPoolAddr);
    startUSDCBalance = await usdc.balanceOf(sgUSDCPoolAddr);
    startSGETHBalance = await sgeth.balanceOf(sgETHPoolAddr);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDT/USDC balance drops by 89%, should still pass', async () => {
    // transfer away 89.9% of pool funds
    await fundSigner(sgUSDTPoolAddr);
    await runAsSigner(sgUSDTPoolAddr, async () => {
      const sgUSDTPoolSigner = await hre.ethers.getSigner(sgUSDTPoolAddr);
      await usdt.connect(sgUSDTPoolSigner).transfer(targetAddr, startUSDTBalance.mul(9).div(10).sub(1));
    });

    await fundSigner(sgUSDCPoolAddr);
    await runAsSigner(sgUSDCPoolAddr, async () => {
      const sgUSDCPoolSigner = await hre.ethers.getSigner(sgUSDCPoolAddr);
      await usdc.connect(sgUSDCPoolSigner).transfer(targetAddr, startUSDCBalance.mul(9).div(10).sub(1));
    });

    await fundSigner(sgETHPoolAddr);
    await runAsSigner(sgETHPoolAddr, async () => {
      const sgETHPoolSigner = await hre.ethers.getSigner(sgETHPoolAddr);
      await sgeth.connect(sgETHPoolSigner).transfer(targetAddr, startSGETHBalance.mul(9).div(10).sub(1));
    });

    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if USDT/USDC balance drops by 90%, should fail', async () => {
    // transfer away enough to get 90% of pool funds
    await runAsSigner(sgUSDTPoolAddr, async () => {
      const sgUSDTPoolSigner = await hre.ethers.getSigner(sgUSDTPoolAddr);
      await usdt.connect(sgUSDTPoolSigner).transfer(targetAddr, 2);
    });

    await runAsSigner(sgUSDCPoolAddr, async () => {
      const sgUSDCPoolSigner = await hre.ethers.getSigner(sgUSDCPoolAddr);
      await usdc.connect(sgUSDCPoolSigner).transfer(targetAddr, 2);
    });

    await runAsSigner(sgETHPoolAddr, async () => {
      const sgETHPoolSigner = await hre.ethers.getSigner(sgETHPoolAddr);
      await sgeth.connect(sgETHPoolSigner).transfer(targetAddr, 2);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
