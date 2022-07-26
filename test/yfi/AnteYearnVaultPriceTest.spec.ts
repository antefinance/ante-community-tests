import hre from 'hardhat';
const { waffle } = hre;

import { AnteYearnVaultPriceTest, AnteYearnVaultPriceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteYearnVaultPriceTest', function () {
  let test: AnteYearnVaultPriceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteYearnVaultPriceTest',
      deployer
    )) as AnteYearnVaultPriceTest__factory;
    test = await factory.deploy('0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9', '100');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.getNewPricePerShare()).to.be.gt('1000');
    expect(await test.originalPricePerShare()).to.be.gt('1000');
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('update can only be called once per 100 blocks', async () => {
    await expect(test.updatePricePerShare()).to.be.revertedWith('Can only update once per preset blocks');
    await evmMineBlocks(100);
    await test.updatePricePerShare();
  });
});
