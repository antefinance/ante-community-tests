import hre from 'hardhat';
const { waffle } = hre;

import { AnteUSDTSupplyTest, AnteUSDTSupplyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUSDTSupplyTest', function () {
  let test: AnteUSDTSupplyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteUSDTSupplyTest',
      deployer
    )) as AnteUSDTSupplyTest__factory;
    test = await factory.deploy('0xdAC17F958D2ee523a2206206994597C13D831ec7');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
