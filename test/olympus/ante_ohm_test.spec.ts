import hre from 'hardhat';
const { waffle, ethers } = hre;

import { AnteOHMBackingTest__factory, AnteOHMBackingTest, IERC20, OlympusTreasury } from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteOHMBackingTest', function () {
  let test: AnteOHMBackingTest;

  let globalSnapshotId: string;

  const INITIAL_TESTING_ETH = ethers.utils.parseEther('10.0').toHexString();

  const _olympusTreasuryAddr = '0x31F8Cc382c9898b273eff4e0b7626a6987C846E8' // Olympus Treasury
  const _ohmTokenAddr = '0x383518188c0c6d7730d91b2c03a03c837814a899'; // OHM Token

  // Reserve Tokens as of block 13089428
  const _daiTokenAddr = '0x6b175474e89094c44da98b954eedeac495271d0f'; // DAI Token
  const _fraxTokenAddr = '0x853d955aCEf822Db058eb8505911ED77F175b99e'; // FRAX Token
  const _wETHAddr =	'0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'; // wETH Token

  // Liquidity Tokens as of block 13089428
  const _slpOhmDaiAddr = '0x34d7d7Aaf50AD4944B70B320aCB24C95fa2def7c';
  const _uniswapOhmFraxAddr = '0x2dcE0dDa1C2f98e0F171DE8333c3c6Fe1BbF4877';
  const _sushiAddr = '0x6B3595068778DD592e39A122f4f5a5cF09C90fE2';
  const _xSushiAddr = '0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272';

  beforeEach(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await ethers.getContractFactory('AnteOHMBackingTest', deployer)) as AnteOHMBackingTest__factory;
    test = await factory.deploy(_olympusTreasuryAddr, _ohmTokenAddr);
    await test.deployed();
  });

  afterEach(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail after DAI withdrawal to external', async () => {
    const LUCKY_RECIPIENT = '0x030ba81f1c18d280636f32af80b9aad02cf0854e'; // Aave: aWETH Token V2 Contract
    await runAsSigner(_olympusTreasuryAddr, async () => {
      const donor = await ethers.getSigner(_olympusTreasuryAddr);
      await hre.network.provider.request({
        method: "hardhat_setBalance",
        params: [_olympusTreasuryAddr, INITIAL_TESTING_ETH],
      });

      const treasuryTokens = [
        _daiTokenAddr,
        _fraxTokenAddr,
        _wETHAddr,
        _slpOhmDaiAddr,
        _uniswapOhmFraxAddr,
        _sushiAddr,
        _xSushiAddr
      ];

      // Withdraw all the tokens
      for (let i = 0; i < treasuryTokens.length; i++) {
        let tokenAddr = treasuryTokens[i];
        let token = <IERC20>await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', tokenAddr, donor);
        let tokenBalance = await token.balanceOf(_olympusTreasuryAddr);
        await token.transfer(LUCKY_RECIPIENT, tokenBalance);
      }

      expect(await test.checkTestPasses()).to.be.false;
    });
  });
});
