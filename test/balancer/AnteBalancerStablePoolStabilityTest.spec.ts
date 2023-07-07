import hre, { ethers } from 'hardhat';
const { waffle } = hre;

import { AnteBalancerStablePoolStabilityTest, AnteBalancerStablePoolStabilityTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { formatBytes32String } from 'ethers/lib/utils';

describe('AnteBalancerStablePoolStabilityTest', function () {
  let test: AnteBalancerStablePoolStabilityTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBalancerStablePoolStabilityTest',
      deployer
    )) as AnteBalancerStablePoolStabilityTest__factory;
    test = await factory.deploy('0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('ratioValid should return true ', async () => {
    expect(await test.ratioValid('100', '33', '3')).to.be.true;
    expect(await test.ratioValid('100', '36', '3')).to.be.true;
    expect(await test.ratioValid('100', '30', '3')).to.be.true;

    expect(await test.ratioValid('160', '40', '4')).to.be.true;
    expect(await test.ratioValid('160', '43', '4')).to.be.true;
    expect(await test.ratioValid('160', '37', '4')).to.be.true;
  });

  it('ratioValid should return false ', async () => {
    expect(await test.ratioValid('100', '37', '3')).to.be.false;
    expect(await test.ratioValid('100', '29', '3')).to.be.false;

    expect(await test.ratioValid('160', '47', '4')).to.be.false;
    expect(await test.ratioValid('160', '34', '4')).to.be.false;
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
