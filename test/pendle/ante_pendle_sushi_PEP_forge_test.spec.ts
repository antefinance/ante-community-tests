import hre from 'hardhat';
const { waffle } = hre;
import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { AntePendleSushiPEPForgeTest, AntePendleSushiPEPForgeTest__factory } from '../../typechain';

describe('AntePendleSushiPEPForgeTest', function () {
  let test: AntePendleSushiPEPForgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AntePendleSushiPEPForgeTest',
      deployer
    )) as AntePendleSushiPEPForgeTest__factory;
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
