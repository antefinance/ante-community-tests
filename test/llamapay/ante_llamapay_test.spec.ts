import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteLlamaPayTest,
  AnteLlamaPayTest__factory,
  LlamaPayFactory,
  LlamaPayFactory__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteLlamaPayTest', function () {
  let test: AnteLlamaPayTest;
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

    const factory = (await hre.ethers.getContractFactory('AnteLlamaPayTest', deployer)) as AnteLlamaPayTest__factory;
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
    await expect(test.setTokenAddress('0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4')).to.be.reverted;
  });

  it('should not allow setting 0x0 as token address', async () => {
    await expect(test.setTokenAddress('0x0000000000000000000000000000000000000000')).to.be.reverted;
  });

  it('should still pass if invalid payer address passed', async () => {
    await test.setPayerAddress('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    expect(await test.checkTestPasses()).to.be.true;
  });
});
