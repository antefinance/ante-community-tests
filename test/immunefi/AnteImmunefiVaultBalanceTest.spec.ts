import hre from 'hardhat';
const { waffle } = hre;

import { AnteImmunefiVaultBalanceTest, AnteImmunefiVaultBalanceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteImmunefiVaultBalanceTest', function () {
  let test: AnteImmunefiVaultBalanceTest;
  let usdc: Contract;

  const vaultAddr = '0xf4a8714f6ca5Bf232F10b308C693448738be0661';
  const usdcAddr = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4'; // throwaway

  let vaultBalance: BigNumber;
  let usdcPrice: BigNumber;
  let vaultBalanceInUSD: BigNumber;
  let thresholdBalance: BigNumber;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteImmunefiVaultBalanceTest',
      deployer
    )) as AnteImmunefiVaultBalanceTest__factory;
    test = await factory.deploy();
    await test.deployed();

    usdc = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', usdcAddr, deployer);

    vaultBalance = await test.getVaultBalance();
    usdcPrice = await test.getUsdcPrice();
    vaultBalanceInUSD = await test.getVaultBalanceInUSD();
    thresholdBalance = await test.getThresholdBalance();

    console.log('Immunefi Vault Balance (USDC): ' + vaultBalance);
    console.log('USDC / USD: ' + usdcPrice);
    console.log('Immunefi Vault Balance (USD): ' + vaultBalanceInUSD);
    console.log('threshold balance (USD): ' + thresholdBalance);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if Vault USDC balance value drops below 1K USD, should fail', async () => {
    // transfer away pool funds
    await fundSigner(vaultAddr);
    await runAsSigner(vaultAddr, async () => {
      const ImmunefiPoolSigner = await hre.ethers.getSigner(vaultAddr);
      await usdc.connect(ImmunefiPoolSigner).transfer(
        targetAddr, vaultBalance.sub(thresholdBalance.mul(usdcPrice).div(10**8)).add(1)
      );
    });
  });
});
