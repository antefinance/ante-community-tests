import hre from 'hardhat';
const { waffle } = hre;

import { AnteYFISupplyTest, AnteYFISupplyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteYFISupplyTest', function () {
  let test: AnteYFISupplyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteYFISupplyTest', deployer)) as AnteYFISupplyTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect((await test.checkTestPasses())).to.be.true;
  });

  it('should update last checked time', async () => {
    const getLastTime = await test.getLastUpdate();
    await evmIncreaseTime(2592000); // 1 Month in seconds
    await evmMineBlocks(1);
    await test.updateSupply();
    const getLastTime2 = await test.getLastUpdate();

    // 20 second cushion incase the local EVM is being slow.
    expect(getLastTime2.sub(getLastTime)).to.be.gt(2592000 - 10);
    expect(getLastTime2.sub(getLastTime)).to.be.lt(2592000 + 10);
  });

  it('should not allow update if less than 1 month has passed', async () => {
    expect(test.updateSupply()).to.be.revertedWith("Can only be updated once per month");
  });
});
