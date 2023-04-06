import hre from 'hardhat';

const { waffle } = hre;

import { BigNumber, providers } from 'ethers';

import { expect } from 'chai';

export function expectAlmostEqual(num1: BigNumber, num2: BigNumber, tolerance: number): void {
  expect(num1.sub(num2).abs()).to.be.lt(tolerance);
}

export async function blockTimestamp(provider?: providers.JsonRpcProvider): Promise<number> {
  return provider ?
    (await provider.getBlock('latest')).timestamp :
    (await waffle.provider.getBlock('latest')).timestamp;
}

export async function blockNumber(provider?: providers.JsonRpcProvider): Promise<number> {
  return provider ? (await provider.getBlock('latest')).number :
    (await waffle.provider.getBlock('latest')).number;
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

export async function evmSetNextBlockTimestamp(timestamp: number, provider?: providers.JsonRpcProvider) {
  provider ?
    await provider.send('evm_setNextBlockTimestamp', [timestamp]) :
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

export async function runAsSignerProvider(provider: providers.JsonRpcProvider, signerAddr: string, fn: () => Promise<void>): Promise<void> {
  await provider.send('hardhat_impersonateAccount', [signerAddr]);
  await fn();
  await provider.send('hardhat_stopImpersonatingAccount', [signerAddr]);
}

export async function fundSigner(signerAddr: string) {
  const ETH_BAL = hre.ethers.utils.parseEther('10000000000');
  await hre.network.provider.request({
    method: 'hardhat_setBalance',
    params: [signerAddr, hre.ethers.utils.hexStripZeros(ETH_BAL.toHexString())],
  });
}

export async function providerFundSigner(provider: providers.JsonRpcProvider, signerAddr: string) {
  const ETH_BAL = hre.ethers.utils.parseEther('10000000000');
  await provider.send('hardhat_setBalance', [signerAddr, hre.ethers.utils.hexStripZeros(ETH_BAL.toHexString())]);
}
