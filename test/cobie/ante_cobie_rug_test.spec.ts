import hre from 'hardhat';
const { waffle } = hre;

import { AnteCobieRugTest, AnteCobieRugTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteCobieRugTest', function () {
  let test: AnteCobieRugTest;

  const cobieAddr = '0x4Cbe68d825d21cB4978F56815613eeD06Cf30152';
  const usdcAddr = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const usdtAddr = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCobieRugTest',
      deployer
    )) as AnteCobieRugTest__factory;
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
