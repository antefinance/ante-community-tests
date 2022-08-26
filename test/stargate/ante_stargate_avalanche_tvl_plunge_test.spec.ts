import hre from 'hardhat';
const { waffle } = hre;

import { AnteStargateAvalancheTVLPlungeTest, AnteStargateAvalancheTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteStargateAvalancheTVLPlungeTest', function () {
  let test: AnteStargateAvalancheTVLPlungeTest;
  let usdt: Contract;
  let usdc: Contract;

  let globalSnapshotId: string;

  const usdtAddr = '0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7';
  const usdcAddr = '0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E';
  const sgUSDTPoolAddr = '0x29e38769f23701A2e4A8Ef0492e19dA4604Be62c';
  const sgUSDCPoolAddr = '0x1205f31718499dBf1fCa446663B532Ef87481fe1';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4';

  let startUSDTBalance: BigNumber;
  let startUSDCBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteStargateAvalancheTVLPlungeTest',
      deployer
    )) as AnteStargateAvalancheTVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get balances on deploy
    usdt = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdtAddr, deployer);
    usdc = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdcAddr, deployer);
    startUSDTBalance = await usdt.balanceOf(sgUSDTPoolAddr);
    startUSDCBalance = await usdc.balanceOf(sgUSDCPoolAddr);
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

    expect(await test.checkTestPasses()).to.be.false;
  });
});
