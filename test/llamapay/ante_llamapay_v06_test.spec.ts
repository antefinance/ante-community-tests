import hre, { ethers } from 'hardhat';
const { waffle } = hre;

import {
  AnteLlamaPayV06Test,
  AnteLlamaPayV06Test__factory,
  LlamaPayFactory,
  LlamaPayFactory__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { defaultAbiCoder } from 'ethers/lib/utils';

describe('AnteLlamaPayV06Test', function () {
  let test: AnteLlamaPayV06Test;
  let llamafactory: LlamaPayFactory;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const llamapayfactory = (await hre.ethers.getContractFactory(
      'LlamaPayFactory',
      deployer
    )) as LlamaPayFactory__factory;
    llamafactory = await llamapayfactory.deploy();
    await llamafactory.deployed();

    await llamafactory.createLlamaPayContract('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    await llamafactory.createLlamaPayContract('0xdAC17F958D2ee523a2206206994597C13D831ec7');

    const llamaAddr = llamafactory.address;

    const factory = (await hre.ethers.getContractFactory(
      'AnteLlamaPayV06Test',
      deployer
    )) as AnteLlamaPayV06Test__factory;
    test = await factory.deploy(llamaAddr);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should not allow setting of an invalid token address', async () => {
    const tokenAddress = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4';
    const payerAddress = ethers.constants.AddressZero;

    const state = defaultAbiCoder.encode(['address', 'address'], [tokenAddress, payerAddress]);

    await expect(test.setStateAndCheckTestPasses(state)).to.be.revertedWith(
      'ANTE: LlamaPay instance not deployed for that token'
    );
  });

  it('should not allow setting 0x0 as token address', async () => {
    const tokenAddress = ethers.constants.AddressZero;
    const payerAddress = ethers.constants.AddressZero;

    const state = defaultAbiCoder.encode(['address', 'address'], [tokenAddress, payerAddress]);

    await expect(test.setStateAndCheckTestPasses(state)).to.be.revertedWith(
      'ANTE: LlamaPay instance not deployed for that token'
    );
  });

  it('should still pass if invalid payer address passed', async () => {
    const tokenAddress = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
    const payerAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

    const state = defaultAbiCoder.encode(['address', 'address'], [tokenAddress, payerAddress]);

    // Set state and check test. We cannot test the return value of a txn.
    await test.setStateAndCheckTestPasses(state);

    // State is already set by previous call.
    expect(await test.tokenAddress()).to.be.equal(tokenAddress);
    expect(await test.payerAddress()).to.be.equal(payerAddress);

    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should return correct state types', async () => {
    expect(await test.getStateTypes()).to.be.eq('address,address');
  });

  it('should return correct state names', async () => {
    expect(await test.getStateNames()).to.be.eq('tokenAddress,payerAddress');
  });
});
