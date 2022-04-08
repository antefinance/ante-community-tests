import hre from 'hardhat';
const { waffle } = hre;

import { AnteUniswapUSDCETHUSDTETHPoolTVLDifference, AnteUniswapUSDCETHUSDTETHPoolTVLDifference__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

describe('AnteUniswapUSDCETHUSDTETHPoolTVLDifference', function () {
  let test: AnteUniswapUSDCETHUSDTETHPoolTVLDifference;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteUniswapUSDCETHUSDTETHPoolTVLDifference', deployer)) as AnteUniswapUSDCETHUSDTETHPoolTVLDifference__factory;
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
