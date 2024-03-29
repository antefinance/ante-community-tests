import hre from 'hardhat';
const { waffle } = hre;

import { IERC20Metadata, OPStackL1BridgePlungeRateTest, OPStackL1BridgePlungeRateTest__factory } from '../../typechain';

import { runAsSigner, evmSnapshot, evmRevert, blockTimestamp, evmMineBlocks, evmIncreaseTime } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

describe('OPStackL1BridgePlungeRateTest', function () {
  let topToken: IERC20Metadata;

  let test: OPStackL1BridgePlungeRateTest;

  let checkpointTime;

  const BRIDGE_ADDR = '0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1';
  const INITIAL_TESTING_ETH = hre.ethers.utils.parseEther('1000.0').toHexString();

  let globalSnapshotId: string;
  let snapshotId: string;
  let topTokenThreshold: BigNumber;
  let topTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    await hre.network.provider.request({
      method: 'hardhat_setBalance',
      params: [BRIDGE_ADDR, INITIAL_TESTING_ETH],
    });

    const [deployer] = waffle.provider.getWallets();
    console.log(deployer.address, await deployer.getBalance(), process.env.NETWORK);
    const factory = (await hre.ethers.getContractFactory(
      'OPStackL1BridgePlungeRateTest',
      deployer
    )) as OPStackL1BridgePlungeRateTest__factory;
    test = await factory.deploy({ gasLimit: 8000000 });
    await test.deployed();

    checkpointTime = await test.lastCheckpointTime();
    const topTokenAddr = await test.tokens(0);
    topToken = <IERC20Metadata>(
      await hre.ethers.getContractAt(
        '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol:IERC20Metadata',
        topTokenAddr
      )
    );
    topTokenThreshold = await test.thresholds(0);
    snapshotId = await evmSnapshot();
  });

  beforeEach(async () => {
    await evmRevert(snapshotId);
    snapshotId = await evmSnapshot();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass after 12 hours', async () => {
    await evmIncreaseTime(60 * 60 * 12 + 1);
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass during min period even if large amount of token was transferred out of the bridge', async () => {
    topTokenBalance = await topToken.balanceOf(BRIDGE_ADDR);
    const toRemove = topTokenBalance.sub(topTokenThreshold);
    const [deployer] = waffle.provider.getWallets();
    await runAsSigner(BRIDGE_ADDR, async () => {
      const tokenHolder = await hre.ethers.getSigner(BRIDGE_ADDR);
      await topToken.connect(tokenHolder).transfer(deployer.address, toRemove.add(1));
    });

    expect(await topToken.balanceOf(BRIDGE_ADDR)).to.equal(topTokenThreshold.sub(1));
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if large amount of tokens transferred out of bridge after min period', async () => {
    await evmIncreaseTime(60 * 60 * 12 + 1);
    await evmMineBlocks(1);

    const topTokenBalance = await topToken.balanceOf(BRIDGE_ADDR);
    const [deployer] = waffle.provider.getWallets();
    await runAsSigner(BRIDGE_ADDR, async () => {
      const topTokenHolder = await hre.ethers.getSigner(BRIDGE_ADDR);

      const toRemove = topTokenBalance.sub(topTokenThreshold);
      await topToken.connect(topTokenHolder).transfer(deployer.address, toRemove.add(1));
    });

    expect(await topToken.balanceOf(BRIDGE_ADDR)).to.equal(topTokenThreshold.sub(1));
    expect(await test.checkTestPasses()).to.be.false;
  });

  it('should pass if large amount of tokens transferred out of bridge after max checkpoint age', async () => {
    const topTokenBalance = await topToken.balanceOf(BRIDGE_ADDR);
    const [deployer] = waffle.provider.getWallets();
    await runAsSigner(BRIDGE_ADDR, async () => {
      const topTokenHolder = await hre.ethers.getSigner(BRIDGE_ADDR);
      const toRemove = topTokenBalance.sub(topTokenThreshold);
      await topToken.connect(topTokenHolder).transfer(deployer.address, toRemove.add(1));
    });

    expect(await topToken.balanceOf(BRIDGE_ADDR)).to.equal(topTokenThreshold.sub(1));
    await evmIncreaseTime(60 * 60 * 72 + 1);
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should not allow checkpointing again within checkpoint interval', async () => {
    // increase time by 47 hours
    checkpointTime = await test.lastCheckpointTime();
    await evmIncreaseTime(60 * 60 * 47 + 1);
    await evmMineBlocks(1);

    await expect(test.checkpoint()).to.be.reverted;
    // check checkpoint state didn't change
    expect(await test.lastCheckpointTime()).to.equal(checkpointTime);
  });

  it('should reset checkpoint data when calling checkpoint() after checkpoint interval', async () => {
    const topTokenBalance = await topToken.balanceOf(BRIDGE_ADDR);
    const toRemove = topTokenBalance.div(2);
    checkpointTime = await test.lastCheckpointTime();
    const [deployer] = waffle.provider.getWallets();
    // transfer some topToken out of topTokentroller to verify test state has changed after checkpoint
    await runAsSigner(BRIDGE_ADDR, async () => {
      const topTokenHolder = await hre.ethers.getSigner(BRIDGE_ADDR);
      await topToken.connect(topTokenHolder).transfer(deployer.address, toRemove);
    });

    await evmIncreaseTime(60 * 60 * 48 + 1);
    await evmMineBlocks(1);

    expect(await test.thresholds(0)).to.equal(topTokenBalance.mul(30).div(100));
    await test.checkpoint();

    expect(await test.lastCheckpointTime()).to.equal(await blockTimestamp());
    expect(await test.lastCheckpointTime()).to.be.gt(checkpointTime);
    expect(await test.thresholds(0)).to.equal(topTokenBalance.sub(toRemove).mul(30).div(100));
  });
});
