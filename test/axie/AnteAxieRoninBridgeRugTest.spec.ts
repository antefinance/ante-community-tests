import hre from 'hardhat';
const { waffle } = hre;

import { AnteAxieRoninBridgeRugTest__factory, AnteAxieRoninBridgeRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAxieRoninBridgeRugTest', function () {
  let test: AnteAxieRoninBridgeRugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAxieRoninBridgeRugTest',
      deployer
    )) as AnteAxieRoninBridgeRugTest__factory;
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
