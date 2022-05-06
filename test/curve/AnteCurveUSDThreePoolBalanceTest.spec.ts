import hre from 'hardhat';
const { waffle } = hre;

import { AnteCurveUSDThreePoolBalanceTest, AnteCurveUSDThreePoolBalanceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCurveUSDThreePoolBalanceTest', function () {
  let test: AnteCurveUSDThreePoolBalanceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteCurveUSDThreePoolBalanceTest', deployer)) as AnteCurveUSDThreePoolBalanceTest__factory;
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
