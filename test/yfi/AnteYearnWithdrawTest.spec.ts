import hre from 'hardhat';
const { waffle } = hre;

import { AnteYearnWithdrawTest, AnteYearnWithdrawTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';


describe('AnteYearnWithdrawTest', function () {
  let test: AnteYearnWithdrawTest;

  let globalSnapshotId: string;

  const [deployer] = waffle.provider.getWallets();
  const USDC_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const yUSDC_VAULT = "0x5f18c75abdae578b483e5f43f12a39cf75b973a9";


  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const factory = (await hre.ethers.getContractFactory('AnteYearnWithdrawTest', deployer)) as AnteYearnWithdrawTest__factory;
    test = await factory.deploy(yUSDC_VAULT, USDC_ADDRESS);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
