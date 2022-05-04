import hre from 'hardhat';
const { waffle } = hre;

import { AntecvxCRVPegTest, AntecvxCRVPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AntecvxCRVPegTest', function () {
  let test: AntecvxCRVPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AntecvxCRVPegTest', deployer)) as AntecvxCRVPegTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('preCheck works as expected', async () => {
    expect(await test.preCheckBlock()).to.eq('0');
    expect(await test.preCheckSlip()).to.eq('0');

    await test.preCheck();

    const currentBlock = await waffle.provider.getBlockNumber();
    expect(await test.preCheckBlock()).to.be.gt((currentBlock - 1).toString());
    expect(await test.preCheckSlip()).to.be.gt('1');
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
