import hre from 'hardhat';
const { waffle, ethers } = hre;

import { UniswapV2PairBalancedAssetsTest, UniswapV2PairBalancedAssetsTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('UniswapV2PairBalancedAssetsTest', function () {
  let test: UniswapV2PairBalancedAssetsTest;

  let globalSnapshotId: string;
  let acceptedDeviation = 1;
  let factoryAddress = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f'; // UniswapV2 factory
  let initialTokenA = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'; // WETH
  let initialTokenB = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'; // USDC

  let stateChangeTokenA = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'; // WETH
  let stateChangeTokenB = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599'; // WBTC

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'UniswapV2PairBalancedAssetsTest',
      deployer
    )) as UniswapV2PairBalancedAssetsTest__factory;
    test = await factory.deploy(acceptedDeviation, factoryAddress, initialTokenA, initialTokenB);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    /*
    const [value0, value1] = await test.getPairReservesValues();
    const diffPercentage = value0.sub(value1).mul(100).div(value0).abs();
    console.log(`
    Reserve0: ${value0}
    Reserve1: ${value1}
    Difference: ${diffPercentage}%
    `);
    */
    expect(await test.checkTestPasses()).to.be.true;
    const stateAbiEncoded = ethers.utils.defaultAbiCoder.encode(
      ['address', 'address'],
      [stateChangeTokenA, stateChangeTokenB]
    );
    await test.setStateAndCheckTestPasses(stateAbiEncoded);
    /*
    const [value0After, value1After] = await test.getPairReservesValues();
    const diffPercentageAfter = value0After.sub(value1After).mul(100).div(value0After).abs();
    console.log(`
    Reserve0: ${value0After}
    Reserve1: ${value1After}
    Difference: ${diffPercentageAfter}%
    `);
    */
    expect(await test.checkTestPasses()).to.be.true;
  });
});
