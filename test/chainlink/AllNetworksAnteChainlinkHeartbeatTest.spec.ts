import hre from 'hardhat';
const { waffle } = hre;

import { AllNetworksAnteChainlinkHeartbeatTest, AllNetworksAnteChainlinkHeartbeatTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AllNetworksAnteChainlinkHeartbeatTest', function () {
  let test: AllNetworksAnteChainlinkHeartbeatTest;

  let globalSnapshotId: string;

  let priceFeeds24h: Record<string, string[]> = {
    optimisticEthereum: [
      '0x39be70e93d2d285c9e71be7f70fc5a45a7777b14', // AUD / USD
      '0x2ff1eb7d0cec35959f0248e9354c3248c6683d9b', // FLOW / USD
    ],
    mainnet: [
      '0x3e7d1eab13ad0104d2750b8863b489d65364e32d', // USDT / USD
      '0x553303d460ee0afb37edff9be42922d8ff63220e', // UNI / USD
    ],
  };
  let priceFeeds1h: Record<string, string[]> = {
    optimisticEthereum: [
      '0xCc232dcFAAE6354cE191Bd574108c1aD03f86450', // LINK / USD
      '0x13e3Ee699D1909E989722E753853AE30b17e08c5', // ETH / USD
    ],
    mainnet: [
      '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419', // ETH / USD
      '0xf4030086522a5beea4988f8ca5b36dbc97bee88c', // BTC / USD,
    ],
  };

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    expect(priceFeeds24h[process.env.NETWORK as string]).to.not.be.undefined;
    expect(priceFeeds1h[process.env.NETWORK as string]).to.not.be.undefined;

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AllNetworksAnteChainlinkHeartbeatTest',
      deployer
    )) as AllNetworksAnteChainlinkHeartbeatTest__factory;
    test = await factory.deploy(
      priceFeeds24h[process.env.NETWORK as string],
      priceFeeds1h[process.env.NETWORK as string]
    );
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it("should pass, unless ran in 'npx hardhat test'", async () => {
    const currentTimestamp = await blockTimestamp();
    if (currentTimestamp > Math.floor(Date.now() / 1000) + 24 * 60 * 60) {
      expect(await test.checkTestPasses()).to.be.false;
    } else {
      expect(await test.checkTestPasses()).to.be.true;
    }
  });
});
