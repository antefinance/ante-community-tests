import hre from 'hardhat';
const { waffle } = hre;

import { AnteUSDCSupplyTest, AnteUSDCSupplyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUSDCSupplyTest', function () {
  let test: AnteUSDCSupplyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteUSDCSupplyTest',
      deployer
    )) as AnteUSDCSupplyTest__factory;
    test = await factory.deploy('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
