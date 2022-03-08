import hre from 'hardhat';
const { waffle, ethers } = hre;

import { AnteTWETHTest__factory, AnteTWETHTest, IERC20 } from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteTWETHTest', function () {
  let test: AnteTWETHTest;

  let globalSnapshotId: string;

  const INITIAL_TESTING_ETH = ethers.utils.parseEther('1000.0').toHexString();

  const _tokemakManagerAddr = '0xa86e412109f77c45a3bc1c5870b880492fb86a14'; // Tokemak Manager
  const _WETH9Addr = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'; // WETH9 Token
  const _tWETHAddr = '0xd3d13a578a53685b4ac36a1bab31912d2b2a2f36'; // Tokemak WETH Pool

  beforeEach(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await ethers.getContractFactory('AnteTWETHTest', deployer)) as AnteTWETHTest__factory;
    test = await factory.deploy(_tokemakManagerAddr, _tWETHAddr, _WETH9Addr);
    await test.deployed();
  });

  afterEach(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
  it('should pass after external wETH deposits', async () => {
    const BENEVOLENT_WETH_DONOR = '0x030ba81f1c18d280636f32af80b9aad02cf0854e'; // Aave: aWETH Token V2 Contract
    await runAsSigner(BENEVOLENT_WETH_DONOR, async () => {
      const donor = await ethers.getSigner(BENEVOLENT_WETH_DONOR);
      await hre.network.provider.request({
        method: 'hardhat_setBalance',
        params: [BENEVOLENT_WETH_DONOR, INITIAL_TESTING_ETH],
      });

      const wETH9Token = <IERC20>(
        await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', _WETH9Addr, donor)
      );
      const tWETHToken = <IERC20>await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', _tWETHAddr);

      await wETH9Token.transferFrom(BENEVOLENT_WETH_DONOR, _tWETHAddr, ethers.utils.parseUnits('4242', 'gwei'));

      const wETHBalancePostTransfer = await wETH9Token.balanceOf(_tWETHAddr);
      const tWETHSupply = await tWETHToken.totalSupply();

      expect(wETHBalancePostTransfer).to.be.above(tWETHSupply);
      expect(await test.checkTestPasses()).to.be.true;
    });
  });

  it('should fail after wETH withdrawal to external', async () => {
    const LUCKY_WETH_RECIPIENT = '0x030ba81f1c18d280636f32af80b9aad02cf0854e'; // Aave: aWETH Token V2 Contract
    await runAsSigner(_tWETHAddr, async () => {
      const donor = await ethers.getSigner(_tWETHAddr);
      await hre.network.provider.request({
        method: 'hardhat_setBalance',
        params: [_tWETHAddr, INITIAL_TESTING_ETH],
      });

      const wETH9Token = <IERC20>(
        await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', _WETH9Addr, donor)
      );
      const tWETHToken = <IERC20>await ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', _tWETHAddr);

      await wETH9Token.transfer(LUCKY_WETH_RECIPIENT, ethers.utils.parseUnits('1337', 'gwei'));

      const wETHBalancePostTransfer = await wETH9Token.balanceOf(_tWETHAddr);
      const tWETHSupply = await tWETHToken.totalSupply();

      expect(wETHBalancePostTransfer).to.be.below(tWETHSupply);
      expect(await test.checkTestPasses()).to.be.false;
    });
  });
});
