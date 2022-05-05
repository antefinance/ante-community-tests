import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteLlamaPayTest,
  AnteLlamaPayTest__factory,
  AntePoolFactory,
  AntePoolFactory__factory,
  AntePool,
  AnteLlamaPayTestChallengerWrapper,
  AnteLlamaPayTestChallengerWrapper__factory,
  MockLlamaPayFactory,
  MockLlamaPayFactory__factory,
  MockLlamaPay,
} from '../../typechain';

import { evmSnapshot, evmRevert, blockNumber, blockTimestamp } from '../helpers';
import { expect } from 'chai';

describe('AnteLlamaPayTestChallengerWrapper', function () {
  let llamaFactory: MockLlamaPayFactory;
  let llama: MockLlamaPay;
  let test: AnteLlamaPayTest;
  let pool: AntePool;
  let poolFactory: AntePoolFactory;
  let wrapper: AnteLlamaPayTestChallengerWrapper;

  let globalSnapshotId: string;

  const ONE_ETH = hre.ethers.utils.parseEther('1');
  const HALF_ETH = ONE_ETH.div(2);
  const ONE_BLOCK_DECAY = hre.ethers.BigNumber.from(100e9);

  const [deployer, secondUser] = waffle.provider.getWallets();

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    // Deploy LlamaPayFactory
    const llamaPayFactory = (await hre.ethers.getContractFactory(
      'MockLlamaPayFactory',
      deployer
    )) as MockLlamaPayFactory__factory;
    llamaFactory = await llamaPayFactory.deploy();
    await llamaFactory.deployed();
    const llamaPayFactoryAddr = llamaFactory.address;

    // create LlamaPay instance and stream
    await llamaFactory.createLlamaPayContract('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'); // USDC
    let response = await llamaFactory.getLlamaPayContractByToken('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    llama = await hre.ethers.getContractAt('MockLlamaPay', response.predictedAddress);
    llama.createStream('0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4', 100);

    // deploy AntePoolFactory
    const antePoolFactory = (await hre.ethers.getContractFactory(
      'AntePoolFactory',
      deployer
    )) as AntePoolFactory__factory;
    poolFactory = await antePoolFactory.deploy();
    await poolFactory.deployed();

    // deploy AnteLlamaPayTest
    const factory = (await hre.ethers.getContractFactory('AnteLlamaPayTest', deployer)) as AnteLlamaPayTest__factory;
    test = await factory.deploy(llamaPayFactoryAddr);
    await test.deployed();

    // deploy Ante Pool and add some stake
    const tx = await poolFactory.createPool(test.address);
    const receipt = await tx.wait();
    // @ts-ignore
    const testPoolAddress = receipt.events[0].args['testPool'];
    pool = await hre.ethers.getContractAt('AntePool', testPoolAddress);
    await pool.stake(false, { value: ONE_ETH });

    // deploy wrapper contract
    const wrapperFactory = (await hre.ethers.getContractFactory(
      'AnteLlamaPayTestChallengerWrapper',
      deployer
    )) as AnteLlamaPayTestChallengerWrapper__factory;
    wrapper = await wrapperFactory.deploy(test.address, testPoolAddress);
    await wrapper.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  // test wrapper is able to challenge
  it('can challenge LlamaPay test through wrapper', async () => {
    await wrapper.challenge({ value: ONE_ETH });
    expect(await pool.getStoredBalance(wrapper.address, true)).to.equal(ONE_ETH);
  });

  // test wrapper is able to remove partial challenge
  it('can remove partial challenge from LlamaPay test through wrapper', async () => {
    expect(await pool.getTotalChallengerStaked()).to.equal(ONE_ETH);
    await wrapper.withdrawChallenge(HALF_ETH);
    expect(await pool.getStoredBalance(wrapper.address, true)).to.equal(HALF_ETH.sub(ONE_BLOCK_DECAY));
  });

  // test wrapper is not able to remove more challenge than exists
  it('cannot remove more challenge than challenged from LlamaPay test through wrapper', async () => {
    await expect(wrapper.withdrawChallenge(ONE_ETH)).to.be.reverted;
  });

  // test wrapper is able to remove entire challenge
  it('can remove all challenge from LlamaPay test through wrapper', async () => {
    await wrapper.withdrawChallengeAll();
    expect(await pool.getStoredBalance(wrapper.address, true)).to.equal(0);
  });

  // test wrapper is able to verify test
  it('can set params and verify LlamaPay test through wrapper', async () => {
    await wrapper.challenge({ value: ONE_ETH });
    expect(await pool.getStoredBalance(wrapper.address, true)).to.equal(ONE_ETH);
    // pass 12 blocks
    for (let i = 0; i < 12; i++) {
      await hre.network.provider.send('evm_mine');
    }
    await wrapper.setParamsAndCheckTest('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', deployer.address);
    expect(await test.tokenAddress()).to.equal('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    expect(await test.payerAddress()).to.equal(deployer.address);
    expect(await pool.numTimesVerified()).to.equal(1);
  });

  // is able to trigger test failure
  it('can trigger test failure from wrapper', async () => {
    // fail llamapay test
    await llama.makeFail();

    // check test (should fail)
    await wrapper.setParamsAndCheckTest('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', deployer.address);
    expect(await pool.pendingFailure()).to.be.true;
  });

  // if test fails, test wrapper is able to claim funds
  it('can claim funds from failed LlamaPay test through wrapper', async () => {
    expect(await pool.pendingFailure()).to.be.true;
    const prevBalance = await deployer.getBalance();
    const payout = await pool.getChallengerPayout(wrapper.address);

    let txpromise = await wrapper.claim();
    const txreceipt = await txpromise.wait();
    let gasCost = txreceipt.effectiveGasPrice.mul(txreceipt.cumulativeGasUsed);

    expect(await deployer.getBalance()).to.equal(prevBalance.add(payout).sub(gasCost));
  });

  // only single person can use wrapper
  it('only single user can use wrapper', async () => {
    await expect(wrapper.connect(secondUser).challenge({ value: ONE_ETH })).to.be.reverted;
  });
});
