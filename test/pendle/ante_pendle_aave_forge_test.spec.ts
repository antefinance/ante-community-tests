import hre from 'hardhat';
const { waffle } = hre;
import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { AntePendleAaveForgeTest, AntePendleAaveForgeTest__factory } from '../../typechain';

describe('AntePendleAaveForgeTest', function () {
  let test: AntePendleAaveForgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AntePendleAaveForgeTest',
      deployer
    )) as AntePendleAaveForgeTest__factory;
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
