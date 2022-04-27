import hre from 'hardhat';
const { waffle } = hre;

import { AnteYFIVaultPPSTest, AnteYFIVaultPPSTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteYFIVaultPPSTest', function () {
  let test: AnteYFIVaultPPSTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteYFIVaultPPSTest', deployer)) as AnteYFIVaultPPSTest__factory;
    test = await factory.deploy('0x5f18c75abdae578b483e5f43f12a39cf75b973a9');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('price should have a value', async () => {
    console.log('price', (await test.getNewPricePerShare()).toString());
    console.log('price', (await test.originalPricePerShare()).toString());
    expect((await test.getNewPricePerShare())).to.be.gt('100');
    expect((await test.originalPricePerShare())).to.be.gt('100');    
  });

  it('should pass', async () => {
    expect((await test.checkTestPasses())).to.be.true;
  });
});
