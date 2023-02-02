import hre from 'hardhat';
const { waffle } = hre;

import { AnteAxieRoninBridgeV2RugTest__factory, AnteAxieRoninBridgeV2RugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAxieRoninBridgeV2RugTest', function () {
  let test: AnteAxieRoninBridgeV2RugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAxieRoninBridgeV2RugTest',
      deployer
    )) as AnteAxieRoninBridgeV2RugTest__factory;
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
