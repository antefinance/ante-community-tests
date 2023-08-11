import hre from 'hardhat';
const { waffle } = hre;

import { AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest, AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest', function () {
  let test: AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest',
      deployer
    )) as AnteChainlinkAVAXUSDonAvalancheDatafeedHeartbeatTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it("should pass, unless ran in 'npx hardhat test'", async () => {
    console.log('Current Block Timestamp: ' + await test.getCurrentTS());
    console.log('Last Update Block Timestamp: ' + await test.getLastUpdateTS());
    console.log('Time From Last Update: ' + await test.getTimeFromLastUpdate());
    const currentTimestamp = await blockTimestamp();
    const heartbeat = 120;
    const buffer = 12;
    if (currentTimestamp > Math.floor(Date.now() / 1000) + heartbeat + buffer) {
      expect(await test.checkTestPasses()).to.be.false;
    } else {
      expect(await test.checkTestPasses()).to.be.true;
    }
  });
});
