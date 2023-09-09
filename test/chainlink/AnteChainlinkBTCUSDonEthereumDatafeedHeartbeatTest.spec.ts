import hre from 'hardhat';
const { waffle } = hre;

import { AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest, AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest', function () {
  let test: AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest',
      deployer
    )) as AnteChainlinkBTCUSDonEthereumDatafeedHeartbeatTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it("should pass, unless ran in 'npx hardhat test'", async () => {
    const currentTimestamp = await blockTimestamp();
    const heartbeat = 3600;
    const buffer = 72;
    if (currentTimestamp > Math.floor(Date.now() / 1000) + heartbeat + buffer) {
      expect(await test.checkTestPasses()).to.be.false;
    } else {
      expect(await test.checkTestPasses()).to.be.true;
    }
  });
});
