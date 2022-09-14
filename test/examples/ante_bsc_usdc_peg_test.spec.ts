import hre from 'hardhat';
const { waffle } = hre;

import { AnteBscUSDCPegTest, AnteBscUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteBscUSDCPegTest', function () {
  let test: AnteBscUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBscUSDCPegTest',
      deployer
    )) as AnteBscUSDCPegTest__factory;
    test = await factory.deploy('0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
