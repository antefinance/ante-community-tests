import hre from 'hardhat';
const { waffle, ethers } = hre;

import { AnteOHMv2BackingTest__factory, AnteOHMv2BackingTest, IERC20, OlympusTreasury } from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteOHMv2BackingTest', function () {
  let test: AnteOHMv2BackingTest;
  let olympusTreasury: string;
  let globalSnapshotId: string;

  const INITIAL_TESTING_ETH = ethers.utils.parseEther('1000.0').toHexString();

  const _olympusAuthorityAddr = '0x1c21f8ea7e39e2ba00bc12d2968d63f4acb38b7a'; // Olympus Treasury
  const _ohmTokenAddr = '0x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5'; // OHM Token

  // Reserve Tokens as of block 14000889 (may be a third one as well but not significant part
  // of treasury reserves)
  const _daiTokenAddr = '0x6b175474e89094c44da98b954eedeac495271d0f'; // DAI Token
  const _fraxTokenAddr = '0x853d955aCEf822Db058eb8505911ED77F175b99e'; // FRAX Token

  // Liquidity Tokens as of block 14000889
  const _slpOhmFraxAddr = '0xb612c37688861f1f90761dc7f382c2af3a50cc39';

  beforeEach(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await ethers.getContractFactory(
      'AnteOHMv2BackingTest',
      deployer
    )) as AnteOHMv2BackingTest__factory;
    test = await factory.deploy(
      _olympusAuthorityAddr,
      _ohmTokenAddr,
      [_slpOhmFraxAddr],
      [_daiTokenAddr, _fraxTokenAddr]
    );

    await test.deployed();
    olympusTreasury = await test.olympusVault();
  });

  afterEach(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail after reserve token withdrawal to external', async () => {
    const LUCKY_RECIPIENT = '0x030ba81f1c18d280636f32af80b9aad02cf0854e'; // Aave: aWETH Token V2 Contract
    await runAsSigner(olympusTreasury, async () => {
      const donor = await ethers.getSigner(olympusTreasury);
      await hre.network.provider.request({
        method: 'hardhat_setBalance',
        params: [olympusTreasury, INITIAL_TESTING_ETH],
      });

      const treasuryTokens = [_daiTokenAddr, _fraxTokenAddr];

      // Withdraw all the tokens
      for (let i = 0; i < treasuryTokens.length; i++) {
        let tokenAddr = treasuryTokens[i];
        let token = <IERC20>await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', tokenAddr, donor);
        let tokenBalance = await token.balanceOf(olympusTreasury);
        await token.transfer(LUCKY_RECIPIENT, tokenBalance);
      }

      expect(await test.checkTestPasses()).to.be.false;
    });
  });
});
