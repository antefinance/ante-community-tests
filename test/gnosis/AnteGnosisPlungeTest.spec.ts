import hre from 'hardhat';
const { waffle } = hre;

import { AnteGnosisTVLPlungeTest, AnteGnosisTVLPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteGnosisTVLPlungeTest', function () {
  let test: AnteGnosisTVLPlungeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteGnosisTVLPlungeTest',
      deployer
    )) as AnteGnosisTVLPlungeTest__factory;
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
