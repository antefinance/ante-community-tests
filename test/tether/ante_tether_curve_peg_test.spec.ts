import hre from 'hardhat';
const { waffle } = hre;

import { AnteUSDTCurvePegTest__factory, AnteUSDTCurvePegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUSDTCurvePegTest', function () {
  let test: AnteUSDTCurvePegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteUSDTCurvePegTest',
      deployer
    )) as AnteUSDTCurvePegTest__factory;
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
