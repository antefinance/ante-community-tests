import hre from 'hardhat';
const { waffle } = hre;
const { loadFixture, provider } = waffle;

import {
  AnteAVLDropTestAvax,
  AnteAVLDropTestAvax__factory,
  AntePoolFactory,
  AntePoolFactory__factory,
  AnteAlwaysPassTest,
  AnteAlwaysPassTest__factory,
  AnteRevertingTest,
  AnteRevertingTest__factory,
} from '../../typechain';

import { Contract } from 'ethers';

import { evmSnapshot, evmRevert, evmMineBlocks, evmIncreaseTime } from '../helpers';
import { expect } from 'chai';
import * as constants from '../constants';

describe.only('AnteAVLDropTestAvax', function () {
  let test: AnteAVLDropTestAvax;

  let snapshotId: string;
  let globalSnapshotId: string;
  let alwaysPassPool1: Contract;
  let alwaysPassPool2: Contract;
  let revertingTest: Contract;
  let revertingPool: Contract;
  let antePoolFactory: AntePoolFactory;

  const wallets = provider.getWallets();
  const [staker, challenger] = wallets;

  before(async () => {
    /* Set up the following state:
     * Ante Test            Stake             Challenge
     * ------------------------------------------------
     * AnteAlwaysPassTest  1 AVAX (unlocked)   500 AVAX
     * AnteAlwaysPassTest  1 AVAX                1 AVAX
     * AnteRevertingTest   1 AVAX                1 AVAX
     */

    // Deploy AntePoolFactory
    const antePoolFactoryFactory = (await hre.ethers.getContractFactory(
      'contracts/libraries/ante-v05-avax/AntePoolFactory.sol:AntePoolFactory',
      staker
    )) as AntePoolFactory__factory;
    antePoolFactory = await antePoolFactoryFactory.deploy();
    await antePoolFactory.deployed();

    // Deploy mock Ante Tests
    const alwaysPassTestFactory = (await hre.ethers.getContractFactory(
      'AnteAlwaysPassTest',
      staker
    )) as AnteAlwaysPassTest__factory;
    const alwaysPassTest1 = await alwaysPassTestFactory.deploy();
    await alwaysPassTest1.deployed();
    const alwaysPassTest2 = await alwaysPassTestFactory.deploy();
    await alwaysPassTest2.deployed();

    const revertingTestFactory = (await hre.ethers.getContractFactory(
      'AnteRevertingTest',
      staker
    )) as AnteRevertingTest__factory;
    revertingTest = await revertingTestFactory.deploy();
    await revertingTest.deployed();

    // Deploy mock Ante Pools
    let tx = await antePoolFactory.createPool(alwaysPassTest1.address);
    let receipt = await tx.wait();
    // @ts-ignore
    const alwaysPassPool1Addr = receipt.events[0].args['testPool'];
    alwaysPassPool1 = await hre.ethers.getContractAt(
      'contracts/libraries/ante-v05-avax/AntePool.sol:AntePool',
      alwaysPassPool1Addr
    );

    tx = await antePoolFactory.createPool(alwaysPassTest2.address);
    receipt = await tx.wait();
    // @ts-ignore
    const alwaysPassPool2Addr = receipt.events[0].args['testPool'];
    alwaysPassPool2 = await hre.ethers.getContractAt(
      'contracts/libraries/ante-v05-avax/AntePool.sol:AntePool',
      alwaysPassPool2Addr
    );

    tx = await antePoolFactory.createPool(revertingTest.address);
    receipt = await tx.wait();
    // @ts-ignore
    const revertingTestAddr = receipt.events[0].args['testPool'];
    revertingPool = await hre.ethers.getContractAt(
      'contracts/libraries/ante-v05-avax/AntePool.sol:AntePool',
      revertingTestAddr
    );

    const poolAddresses = [alwaysPassPool1.address, alwaysPassPool2.address, revertingPool.address];

    // Set up stake/challenge in pools
    // using ONE_ETH constant but works for AVAX as well
    await alwaysPassPool1.connect(staker).stake(false, { value: constants.ONE_ETH });
    await alwaysPassPool1.connect(challenger).stake(true, { value: constants.ONE_ETH.mul(500) });

    await alwaysPassPool2.connect(staker).stake(false, { value: constants.ONE_ETH });
    await alwaysPassPool2.connect(challenger).stake(true, { value: constants.ONE_ETH });

    await revertingPool.connect(staker).stake(false, { value: constants.ONE_ETH });
    await revertingPool.connect(challenger).stake(true, { value: constants.ONE_ETH });

    // intiate withdraw of some of stake and prime challengers
    await alwaysPassPool1.connect(staker).unstakeAll(false);
    await evmIncreaseTime(constants.ONE_DAY_IN_SECONDS + 1);
    await evmMineBlocks(84);

    // Deploy AnteAVLDropTest
    const factory = (await hre.ethers.getContractFactory(
      'AnteAVLDropTestAvax',
      staker
    )) as AnteAVLDropTestAvax__factory;
    test = await factory.deploy(poolAddresses);
    await test.deployed();

    globalSnapshotId = await evmSnapshot();
    snapshotId = await evmSnapshot();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  beforeEach(async () => {
    await evmRevert(snapshotId);
    snapshotId = await evmSnapshot();
  });

  // Check test passes immediately after deploy
  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check totalAVL = sum of the pool balances in tested contracts ("sub-pools")
  it('currentAVL = sum of tested contract AVLs', async () => {
    expect(await test.getCurrentAVL()).to.equals(
      (await provider.getBalance(alwaysPassPool1.address))
        .add(await provider.getBalance(alwaysPassPool2.address))
        .add(await provider.getBalance(revertingPool.address))
    );
  });

  // Check totalAVL remains unchanged if stake withdrawn after deployment
  it("avlThreshold doesn't change post-deployment if unstaking tested contract", async () => {
    const avlThreshold = await test.avlThreshold();
    await alwaysPassPool1.connect(staker).withdrawStake();
    expect(await test.avlThreshold()).to.equals(avlThreshold);
  });

  // Check totalAVL remains unchanged if challenge withdrawn after deployment
  it("avlThreshold doesn't change post-deployment if un-challenging tested contract", async () => {
    const avlThreshold = await test.avlThreshold();
    await alwaysPassPool2.connect(challenger).unstakeAll(true);
    expect(await test.avlThreshold()).to.equals(avlThreshold);
  });

  // Check avlThreshold = sum of sub-pool balances in tested contracts / 100
  it('avlThreshold = sum of tested contract AVLs / 100', async () => {
    expect(await test.avlThreshold()).to.equals(
      (await provider.getBalance(alwaysPassPool1.address))
        .add(await provider.getBalance(alwaysPassPool2.address))
        .add(await provider.getBalance(revertingPool.address))
        .div(100)
    );
  });

  // Check test still passes when AVL added to a tested contract (stake)
  it('still passes after staking tested contract', async () => {
    await alwaysPassPool1.connect(staker).stake(false, { value: constants.ONE_ETH });
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test still passes when AVL added to a tested contract (challenge)
  it('still passes after challenging tested contract', async () => {
    await alwaysPassPool1.connect(challenger).stake(true, { value: constants.ONE_ETH });
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test still passes after withdrawing a small amount of stake from a tested contract
  it('still passes after unstaking small amount from tested contract', async () => {
    await alwaysPassPool1.connect(staker).withdrawStake();
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test still passes after withdrawing a small amount of challenge from a tested contract
  it('still passes after un-challenging small amount from tested contract', async () => {
    await alwaysPassPool2.connect(challenger).unstakeAll(true);
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test still passes if one of the tested contracts fails but total AVL high enough
  it('still passes if one sub-pool fails but total AVL high enough', async () => {
    await revertingTest.setWillRevert(true);
    await revertingPool.connect(challenger).checkTest();
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test still passes if one tested contract fails and challengers claim but total AVL still high enough
  it('still passes if one test fails and challenger claimed but total AVL high enough', async () => {
    await revertingTest.setWillRevert(true);
    await revertingPool.connect(challenger).checkTest();
    await revertingPool.connect(challenger).claim();
    expect(await test.checkTestPasses()).to.be.true;
  });

  // Check test fails if enough AVL withdrawn
  it('fails when enough is withdrawn from a tested contract', async () => {
    // unstakes 500 ETH of 505 ETH total (99% drop)
    await alwaysPassPool1.connect(challenger).unstakeAll(true);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
