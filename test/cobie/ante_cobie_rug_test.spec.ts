import hre from 'hardhat';
const { waffle } = hre;

import { IERC20, AnteCobieRugTest, AnteCobieRugTest__factory } from '../../typechain';

import { runAsSigner, evmSnapshot, evmRevert, evmIncreaseTime } from '../helpers';
import { expect } from 'chai';

describe('AnteCobieRugTest', function () {
  let test: AnteCobieRugTest;
  let usdc: IERC20;
  let usdt: IERC20;

  const COBIE_ADDRESS = '0x4Cbe68d825d21cB4978F56815613eeD06Cf30152';
  const USDC_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const USDT_ADDRESS = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    usdc = <IERC20>(
      await hre.ethers.getContractAt('@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20', USDC_ADDRESS)
    );

    usdt = <IERC20>(
      await hre.ethers.getContractAt('@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20', USDT_ADDRESS)
    );

    const INITIAL_TESTING_ETH = hre.ethers.utils.parseEther('1000.0').toHexString();

    await hre.network.provider.request({
      method: 'hardhat_setBalance',
      params: [COBIE_ADDRESS, INITIAL_TESTING_ETH],
    });

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteCobieRugTest', deployer)) as AnteCobieRugTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if funds removed before bet expiry', async () => {
    // transfer 10,000 USDC from escrow wallet to me
    await runAsSigner(COBIE_ADDRESS, async () => {
      const cobie = await hre.ethers.getSigner(COBIE_ADDRESS);
      await usdc.connect(cobie).transfer('0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4', '10000000000');
    });

    expect(await test.checkTestPasses()).to.be.false;
  });

  it('should pass after bet expiry even if funds removed', async () => {
    // increase time 1 year
    await evmIncreaseTime(31536000);

    // transfer 10,000 USDC from escrow wallet to me
    await runAsSigner(COBIE_ADDRESS, async () => {
      const cobie = await hre.ethers.getSigner(COBIE_ADDRESS);
      await usdc.connect(cobie).transfer('0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4', '10000000000');
    });

    expect(await test.checkTestPasses()).to.be.true;
  });
});
