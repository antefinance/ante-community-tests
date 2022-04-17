import hre from 'hardhat';
const { waffle } = hre;

import { AnteWildCreditOracleTest__factory, AnteWildCreditOracleTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteWildCreditOracleTest', function () {
  let test: AnteWildCreditOracleTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteWildCreditOracleTest',
      deployer
    )) as AnteWildCreditOracleTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
