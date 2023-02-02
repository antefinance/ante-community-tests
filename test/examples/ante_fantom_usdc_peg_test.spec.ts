import hre from 'hardhat';
const { waffle } = hre;

import { AnteFantomUSDCPegTest, AnteFantomUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

describe('AnteFantomUSDCPegTest', function () {
  if (process.env.NETWORK != 'fantom') return;

  let test: AnteFantomUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteFantomUSDCPegTest',
      deployer
    )) as AnteFantomUSDCPegTest__factory;
    test = await factory.deploy('0x04068da6c83afcfa0e13ba15a6696662335d5b75');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
