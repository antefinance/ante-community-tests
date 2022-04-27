import hre from 'hardhat';
const { waffle } = hre;

import { AnteYearnVaultPriceTest, AnteYearnVaultPriceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteYearnVaultPriceTest', function () {
  let test: AnteYearnVaultPriceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteYearnVaultPriceTest', deployer)) as AnteYearnVaultPriceTest__factory;
    test = await factory.deploy('0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9');
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
    console.log((await test.getNewPricePerShare()).toString());
    expect(await test.checkTestPasses()).to.be.true;
  });
});
