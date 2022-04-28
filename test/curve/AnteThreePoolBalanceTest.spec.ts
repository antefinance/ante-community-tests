import hre from 'hardhat';
const { waffle } = hre;

import { AnteThreePoolBalanceTest, AnteThreePoolBalanceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteThreePoolBalanceTest', function () {
  let test: AnteThreePoolBalanceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteThreePoolBalanceTest', deployer)) as AnteThreePoolBalanceTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('values (100, 120, 60) should pass', async () => {
    expect(await test.isBalanced(100, 120, 60)).to.be.true;
  });

  it('values (100, 150, 60) should fail', async () => {
    expect(await test.isBalanced(100, 150, 60)).to.be.false;
  });
});
