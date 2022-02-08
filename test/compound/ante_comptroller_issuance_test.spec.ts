import hre from 'hardhat';
const { waffle } = hre;

import { IERC20, AnteComptrollerIssuanceTest, AnteComptrollerIssuanceTest__factory } from '../../typechain';

import { runAsSigner, evmSnapshot, evmRevert, evmIncreaseTime, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AnteComptrollerIssuanceTest', function () {
  let comp: IERC20;

  let test: AnteComptrollerIssuanceTest;

  let checkpointTime;

  const INITIAL_TESTING_ETH = hre.ethers.utils.parseEther('1000.0').toHexString();
  const COMPTROLLER_ADDRESS = '0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B';

  let globalSnapshotId: string;
  let snapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    comp = <IERC20>(
      await hre.ethers.getContractAt(
        '@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20',
        '0xc00e94cb662c3520282e6f5717214004a7f26888'
      )
    );

    await hre.network.provider.request({
      method: 'hardhat_setBalance',
      params: [COMPTROLLER_ADDRESS, INITIAL_TESTING_ETH],
    });

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteComptrollerIssuanceTest',
      deployer
    )) as AnteComptrollerIssuanceTest__factory;
    test = await factory.deploy();
    await test.deployed();

    checkpointTime = await test.lastCheckpointTime();

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
    await evmIncreaseTime(43201);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass if COMP is transferred into contract', async () => {
    const RESERVOIR = '0x2775b1c75658be0f640272ccb8c72ac986009e38';
    const compBalance = await comp.balanceOf(COMPTROLLER_ADDRESS);

    await hre.network.provider.request({
      method: 'hardhat_setBalance',
      params: [RESERVOIR, INITIAL_TESTING_ETH],
    });

    await runAsSigner(RESERVOIR, async () => {
      const compHolder = await hre.ethers.getSigner(RESERVOIR);
      // transfer 1000 COMP into comptroller
      await comp.connect(compHolder).transfer(COMPTROLLER_ADDRESS, '1000000000000000000000');
    });

    expect(await comp.balanceOf(COMPTROLLER_ADDRESS)).to.equal(compBalance.add('1000000000000000000000'));
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass during min period even if large amount of COMP transferred out of comptroller', async () => {
    const compBalance = await comp.balanceOf(COMPTROLLER_ADDRESS);

    await runAsSigner(COMPTROLLER_ADDRESS, async () => {
      const compHolder = await hre.ethers.getSigner(COMPTROLLER_ADDRESS);

      // transfer 10000 COMP out of comptroller
      await comp.connect(compHolder).transfer(comp.address, '10000000000000000000000');
    });

    expect(await comp.balanceOf(COMPTROLLER_ADDRESS)).to.equal(compBalance.sub('10000000000000000000000'));
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if large amount of COMP transferred out of comptroller after min period', async () => {
    // increase time by 12 hours and 1 second
    await evmIncreaseTime(43201);

    const compBalance = await comp.balanceOf(COMPTROLLER_ADDRESS);

    await runAsSigner(COMPTROLLER_ADDRESS, async () => {
      const compHolder = await hre.ethers.getSigner(COMPTROLLER_ADDRESS);

      // transfer 6000 COMP out of comptroller
      await comp.connect(compHolder).transfer(comp.address, '6000000000000000000000');
    });

    expect(await comp.balanceOf(COMPTROLLER_ADDRESS)).to.equal(compBalance.sub('6000000000000000000000'));
    expect(await test.checkTestPasses()).to.be.false;
  });

  it('should not allow checkpointing again within checkpoint interval', async () => {
    // increase time by 47 hours
    const checkpointTime = await test.lastCheckpointTime();
    await evmIncreaseTime(169200);

    await expect(test.checkpoint()).to.be.reverted;
    // check checkpoint state didn't change
    expect(await test.lastCheckpointTime()).to.equal(checkpointTime);
  });

  it('should reset checkpoint data when calling checkpoint() after checkpoint interval', async () => {
    const compBalance = await comp.balanceOf(COMPTROLLER_ADDRESS);
    const checkpointTime = await test.lastCheckpointTime();
    // transfer some COMP out of comptroller to verify test state has changed after checkpoint
    await runAsSigner(COMPTROLLER_ADDRESS, async () => {
      const compHolder = await hre.ethers.getSigner(COMPTROLLER_ADDRESS);

      // transfer 6000 COMP out of comptroller
      await comp.connect(compHolder).transfer(comp.address, '6000000000000000000000');
    });

    // increase time by 48 hours and 1 second
    await evmIncreaseTime(172801);

    await test.checkpoint();

    expect(await test.lastCheckpointTime()).to.equal(await blockTimestamp());
    expect(await test.lastCheckpointTime()).to.be.gt(checkpointTime);
    expect(await test.lastCompBalance()).to.equal(compBalance.sub('6000000000000000000000'));
  });
});
