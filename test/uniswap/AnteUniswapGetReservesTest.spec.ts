import hre from 'hardhat';
const { waffle } = hre;

import { AnteUniswapGetReservesTest, AnteUniswapGetReservesTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUniswapGetReservesTest', function () {
  let test: AnteUniswapGetReservesTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteUniswapGetReservesTest', deployer)) as AnteUniswapGetReservesTest__factory;
    test = await factory.deploy('0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc', '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should return proper difference', async () => {
    expect(await test.calculatePercentage('16585796244854', '116598880842818', '100010033')).to.eq('14');
  });

  it('should return proper difference', async () => {
    expect(await test.calculatePercentage('2', '4', '200000000')).to.eq('100');
  });

  it('should return proper difference', async () => {
    expect(await test.calculatePercentage('2', '4', '100000000')).to.eq('50');
  });

  it('should pass', async () => {
    await test.preCall();
    expect(await test.checkTestPasses()).to.be.true;
  });
});