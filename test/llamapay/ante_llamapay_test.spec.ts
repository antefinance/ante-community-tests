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

    await llamafactory.createPayContract('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    await llamafactory.createPayContract('0xdAC17F958D2ee523a2206206994597C13D831ec7');

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
});
