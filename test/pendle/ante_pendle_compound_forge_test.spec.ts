import hre from 'hardhat';
const { waffle } = hre;
import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { AntePendleCompoundForgeTest, AntePendleCompoundForgeTest__factory } from '../../typechain';

describe('AntePendleCompoundForgeTest', function () {
  let test: AntePendleCompoundForgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AntePendleCompoundForgeTest',
      deployer
    )) as AntePendleCompoundForgeTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.callStatic.checkTestPasses()).to.be.true;
  });
});
