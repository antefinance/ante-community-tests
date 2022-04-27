import hre from 'hardhat';
const { waffle } = hre;

import { AnteYFITVLTest, AnteYFITVLTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteYFITVLTest', function () {
  let test: AnteYFITVLTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteYFITVLTest', deployer)) as AnteYFITVLTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });
  it('balances should have a number', async () => {
    console.log((await test.getBalance()).toString());
    console.log((await test.originalBalance()).toString());

    expect(await test.getBalance()).to.be.gt('1111111');
    expect(await test.originalBalance()).to.be.gt('1111111');
  });

  it('should pass', async () => {
    expect((await test.checkTestPasses())).to.be.true;
  });
});
