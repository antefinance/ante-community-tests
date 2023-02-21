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
  const tokens = {
    WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    WBTC: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
    BAT: '0x0D8775F648430679A709E98d2b0Cb6250d2887EF',
  };

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'UniswapV2PairBalancedAssetsTest',
      deployer
    )) as UniswapV2PairBalancedAssetsTest__factory;
    test = await factory.deploy(acceptedDeviation, factoryAddress, tokens.WETH, tokens.USDC, { gasLimit: 8000000 });
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

    // test with WETH and USDC that have a direct USD price feed
    expect(await test.checkTestPasses()).to.be.true;

    // test with WETH and BAT that have a USD price feed via ETH
    let stateAbiEncoded = ethers.utils.defaultAbiCoder.encode(['address', 'address'], [tokens.WETH, tokens.BAT]);
    await test.setStateAndCheckTestPasses(stateAbiEncoded);

    expect(await test.checkTestPasses()).to.be.true;

    // test with WETH - direct USD feed and WBTC - feed via BTC
    stateAbiEncoded = ethers.utils.defaultAbiCoder.encode(['address', 'address'], [tokens.WETH, tokens.WBTC]);
    await test.setStateAndCheckTestPasses(stateAbiEncoded);

    expect(await test.checkTestPasses()).to.be.true;
  });
});
