import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteStargateEthereumTotalTVLPlungeTest,
  AnteStargateEthereumTotalTVLPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteStargateEthereumTotalTVLPlungeTest', function () {
  let test: AnteStargateEthereumTotalTVLPlungeTest;
  let usdt: Contract;
  let usdc: Contract;
  let sgeth: Contract;

  let globalSnapshotId: string;

  const usdtAddr = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
  const usdcAddr = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const sgethAddr = '0x72E2F4830b9E45d52F80aC08CB2bEC0FeF72eD9c';

  const sgUSDTPoolAddr = '0x38EA452219524Bb87e18dE1C24D3bB59510BD783';
  const sgUSDCPoolAddr = '0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56';
  const sgETHPoolAddr = '0x101816545F6bd2b1076434B54383a1E633390A2E';
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
      'AnteStargateEthereumTotalTVLPlungeTest',
      deployer
    )) as AnteStargateEthereumTotalTVLPlungeTest__factory;
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
