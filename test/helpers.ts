import hre from 'hardhat';

const { waffle } = hre;

import { BigNumber } from 'ethers';

import { expect } from 'chai';
import { HardhatNetworkHDAccountsConfig, HardhatRuntimeEnvironment } from 'hardhat/types';
import * as zksync from 'zksync-web3';
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';

export function expectAlmostEqual(num1: BigNumber, num2: BigNumber, tolerance: number): void {
  expect(num1.sub(num2).abs()).to.be.lt(tolerance);
}

export async function blockTimestamp(): Promise<number> {
  return (await waffle.provider.getBlock('latest')).timestamp;
}

export async function blockNumber(): Promise<number> {
  return (await waffle.provider.getBlock('latest')).number;
}

export async function evmSnapshot(): Promise<any> {
  return await hre.network.provider.request({
    method: 'evm_snapshot',
    params: [],
  });
}

export async function evmRevert(snapshotId: string): Promise<void> {
  await hre.network.provider.request({
    method: 'evm_revert',
    params: [snapshotId],
  });
}

export async function evmIncreaseTime(seconds: number) {
  await hre.network.provider.send('evm_increaseTime', [seconds]);
}

export async function evmSetNextBlockTimestamp(timestamp: number) {
  await hre.network.provider.send('evm_setNextBlockTimestamp', [timestamp]);
}

export async function evmMineBlocks(numBlocks: number) {
  for (let i = 0; i < numBlocks; i++) {
    await hre.network.provider.send('evm_mine');
  }
}

export async function evmLastMinedBlockNumber(): Promise<BigNumber> {
  return BigNumber.from(await hre.network.provider.send('eth_blockNumber'));
}

export async function calculateGasUsed(txpromise: any): Promise<BigNumber> {
  const txreceipt = await txpromise.wait();
  return txreceipt.effectiveGasPrice.mul(txreceipt.cumulativeGasUsed);
}

export async function runAsSigner(signerAddr: string, fn: () => Promise<void>): Promise<void> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [signerAddr],
  });
  await fn();
  await hre.network.provider.request({
    method: 'hardhat_stopImpersonatingAccount',
    params: [signerAddr],
  });
}

export async function fundSigner(signerAddr: string) {
  const ETH_BAL = hre.ethers.utils.parseEther('10000000000');
  await hre.network.provider.request({
    method: 'hardhat_setBalance',
    params: [signerAddr, hre.ethers.utils.hexStripZeros(ETH_BAL.toHexString())],
  });
}

export function zksyncSignerFromHre(hre: HardhatRuntimeEnvironment): zksync.Wallet {
  let zkSyncWallet: zksync.Wallet;
  const mnemonic = (hre.network.config.accounts as HardhatNetworkHDAccountsConfig).mnemonic;
  if (mnemonic) {
    zkSyncWallet = zksync.Wallet.fromMnemonic(mnemonic);
  } else {
    zkSyncWallet = new zksync.Wallet((hre.network.config.accounts as string[])[0]);
  }
  return zkSyncWallet;
}

export async function getZksyncDeployer(hre: HardhatRuntimeEnvironment): Promise<Deployer> {
  const zksyncDeployerWallet = zksyncSignerFromHre(hre);
  const zksyncDeployer = new Deployer(hre, zksyncDeployerWallet);
  return zksyncDeployer;
}