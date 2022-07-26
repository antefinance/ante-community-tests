import hre from 'hardhat';
const { waffle } = hre;

import { AnteConvexCRVPoolBalanceTest, AnteConvexCRVPoolBalanceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteConvexCRVPoolBalanceTest', function () {
  let test: AnteConvexCRVPoolBalanceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteConvexCRVPoolBalanceTest',
      deployer
    )) as AnteConvexCRVPoolBalanceTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should return the stronger currency', async () => {
    const USDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
    const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
    const WBTC = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599';
    const DAI = '0x6B175474E89094C44Da98b954EedeAC495271d0F';

    expect(await test.getStrongerCurrency(USDC, WBTC)).to.equal(WBTC);
    expect(await test.getStrongerCurrency(WETH, WBTC)).to.equal(WBTC);
    expect(await test.getStrongerCurrency(WETH, DAI)).to.equal(WETH);
    expect(await test.getStrongerCurrency(WETH, WETH)).to.equal('0x0000000000000000000000000000000000000000');
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
