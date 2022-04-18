import hre from 'hardhat';
const { waffle } = hre;

import { AnteDumpTest, AnteDumpTest__factory, BasicERC20, BasicERC20__factory } from '../../typechain';
import ERC20 from '../ABI/ERC20';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ONE_DAY_IN_SECONDS } from '../constants';

describe('AnteDumpTest', function () {
  let test: AnteDumpTest;

  let globalSnapshotId: string;

  const [admin, owner, burnWallet, wallet1, wallet2, wallet3, wallet4] = waffle.provider.getWallets();

  let TEST_TOKEN: BasicERC20;

  const YEAR_IN_SECONDS_STR = '31536000';
  const YEAR_IN_SECONDS = 31536000;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    
    const factory = (await hre.ethers.getContractFactory('AnteDumpTest', deployer)) as AnteDumpTest__factory;
    const testTokenFactory = (await hre.ethers.getContractFactory('BasicERC20', deployer)) as BasicERC20__factory;
    
    TEST_TOKEN = await testTokenFactory.connect(owner).deploy();
    await TEST_TOKEN.deployed();
    await TEST_TOKEN.connect(owner).mint('1000000000000000000000000', wallet1.address);

    test = await factory.deploy([TEST_TOKEN.address], [wallet1.address], '50', YEAR_IN_SECONDS_STR, admin.address);
    await test.deployed();

  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  // Testing the time based threshold
  it('should return 25% threshold', async () => {
    expect(await test.getAllowedPercentThreshold('10', '12', '16')).to.eq('25');
  });

  it('should return 50% threshold', async () => {
    expect(await test.getAllowedPercentThreshold('10', '12', '10')).to.eq('50');
  });

  it('should return 24% on real world block times', async () => {
    expect(await test.getAllowedPercentThreshold('1680215603', '31536000', '1695983604')).to.eq('24');
  });

  // General tests
  it('should pass', async () => {
    await TEST_TOKEN.connect(wallet1).transfer(burnWallet.address, '500000000000000000000000');

    expect((await test.checkTestPasses())).to.be.true;
  });

  it('should fail then pass after 1 week elapsed time', async () => {
    await TEST_TOKEN.connect(owner).mint('1000000000000000000000000', wallet2.address);
    await test.connect(admin).addWallet(wallet2.address, TEST_TOKEN.address, YEAR_IN_SECONDS);
    await TEST_TOKEN.connect(wallet2).transfer(burnWallet.address, '520000000000000000000000');

    expect((await test.checkTestPasses())).to.be.false;

    await evmIncreaseTime(ONE_DAY_IN_SECONDS * 8);
    await evmMineBlocks(1);
    expect((await test.checkTestPasses())).to.be.true;
  });

  it('should pass with a threshold of 25%', async () => {
    await TEST_TOKEN.connect(owner).mint('1000000000000000000000000', wallet3.address);
    await test.connect(admin).addWallet(wallet3.address, TEST_TOKEN.address, YEAR_IN_SECONDS_STR);

    await TEST_TOKEN.connect(wallet3).transfer(burnWallet.address, '500000000000000000000000');
    await evmIncreaseTime(YEAR_IN_SECONDS / 2);
    await evmMineBlocks(1);

    await TEST_TOKEN.connect(wallet3).transfer(burnWallet.address, '24000000000000000000000');
    expect((await test.checkTestPasses())).to.be.true;  
  });

  // Test addWallet function
  it('should add a wallet', async () => {
    await TEST_TOKEN.connect(owner).mint('1000000000000000000000000', wallet4.address);

    const oldWalletsLength = (await test.getWallets()).toString().length;
    await test.connect(admin).addWallet(wallet4.address, TEST_TOKEN.address, YEAR_IN_SECONDS_STR);
    
    const newWallets = (await test.getWallets()).toString();
    const newPair = newWallets.substring(oldWalletsLength + 1, newWallets.length).split(',');

    expect(newPair[0]).to.eq(wallet4.address);
    expect(newPair[1]).to.eq(TEST_TOKEN.address);
    expect(newPair[2]).to.eq('1000000000000000000000000');
    expect(newPair[4]).to.eq(YEAR_IN_SECONDS_STR);

    expect(true).to.be.true;
  });

  it('should revert when adding a wallet without admin acount', async() => {
    await expect(test.connect(wallet1).addWallet(wallet4.address, TEST_TOKEN.address, YEAR_IN_SECONDS_STR)).to.be.revertedWith('ANTE: Must be an admin or owner');
  }); 
});
