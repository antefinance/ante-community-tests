import hre from 'hardhat';
const { waffle } = hre;

import { AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest, AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest Chainlink Arbitrum', function () {
  let test: AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest',
      deployer
    )) as AnteChainlinkLINKUSDDatafeedHeartbeatArbitrumTest__factory;
    test = await factory.deploy();
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
