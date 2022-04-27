import hre from 'hardhat';
const { waffle } = hre;

import { AnteYFITVLPlungeTest, AnteYFITVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteYFITVLPlungeTest', function () {
  let test: AnteYFITVLPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteYFITVLPlungeTest', deployer)) as AnteYFITVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect((await test.checkTestPasses())).to.be.true;
  });

  it('balance should be something real', async () => {
    expect(await test.getBalance()).to.be.gt(111111); 
    expect(await test.originalBalance()).to.be.gt(111111);
  })
});
