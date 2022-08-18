import hre from 'hardhat';
const { waffle } = hre;
import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { AntePendleSushiETHUSDCForgeTest, AntePendleSushiETHUSDCForgeTest__factory } from '../../typechain';

describe('AntePendleSushiETHUSDCForgeTest', function () {
  let test: AntePendleSushiETHUSDCForgeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AntePendleSushiETHUSDCForgeTest',
      deployer
    )) as AntePendleSushiETHUSDCForgeTest__factory;
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
