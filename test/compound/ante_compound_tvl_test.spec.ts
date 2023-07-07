import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteCompoundTVLTest__factory,
  AnteCompoundTVLTest,
  CEther,
  CErc20,
  ComptrollerInterface,
  IERC20,
} from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteCompoundTVLTest', function () {
  let dai: IERC20;
  let wbtc: IERC20;

  let test: AnteCompoundTVLTest;
  let cDAI: CErc20;
  let cWBTC: CErc20;
  let cETH: CEther;

  let comptroller: ComptrollerInterface;
  let globalSnapshotId: string;
  let snapshotId: string;

  let LARGE_DAI_HOLDER: string;

  const [deployer] = waffle.provider.getWallets();

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    comptroller = <ComptrollerInterface>(
      await hre.ethers.getContractAt('ComptrollerInterface', '0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B')
    );
    cDAI = <CErc20>await hre.ethers.getContractAt('CErc20', '0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643');
    cWBTC = <CErc20>await hre.ethers.getContractAt('CErc20', '0xccF4429DB6322D5C611ee964527D42E5d685DD6a');
    cETH = <CEther>await hre.ethers.getContractAt('CEther', '0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5');

    dai = <IERC20>(
      await hre.ethers.getContractAt(
        '@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20',
        '0x6b175474e89094c44da98b954eedeac495271d0f'
      )
    );
    wbtc = <IERC20>(
      await hre.ethers.getContractAt(
        '@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20',
        '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599'
      )
    );

    // get a dai holding wallet to supply collateral
    LARGE_DAI_HOLDER = '0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8';
    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);

      // deposit 100,000 DAI
      await dai.connect(supplier).approve(cDAI.address, '1000000000000000000000000000000000000000');
      await cDAI.connect(supplier).mint('100000000000000000000000');
      // enable use as collateral
      await comptroller.connect(supplier).enterMarkets([cDAI.address]);

      // borrow 0.25 WBTC
      await cWBTC.connect(supplier).borrow('25000000');
    });

    const factory = (await hre.ethers.getContractFactory(
      'AnteCompoundTVLTest',
      deployer
    )) as AnteCompoundTVLTest__factory;
    test = await factory.deploy();
    await test.deployed();

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

  it('should pass after underlying token transferred directly into contract', async () => {
    // transfer 200,000,000 DAI into the cDAI contract

    const orig_dai_balance = await dai.balanceOf(cDAI.address);

    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);
      await dai.connect(supplier).transfer(cDAI.address, '200000000000000000000000000');
    });

    expect(await dai.balanceOf(cDAI.address)).to.be.equal(orig_dai_balance.add('200000000000000000000000000'));
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass after supplying more assets', async () => {
    const cdai_balance = await cDAI.totalSupply();

    // supply more dai to the cDAI contract
    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);

      await cDAI.connect(supplier).mint('200000000000000000000000000');
    });

    expect(await cDAI.totalSupply()).to.be.gt(cdai_balance);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass after borrowing assets', async () => {
    const ethBorrowBalance = await cETH.totalBorrows();

    // supply more dai to the cDAI contract
    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);

      // borrow 10 ETH
      await cETH.connect(supplier).borrow('10000000000000000000');
    });

    expect(await cETH.totalBorrows()).to.be.gt(ethBorrowBalance);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass after repaying loan', async () => {
    const wbtcBorrowBalance = await cWBTC.totalBorrows();

    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);
      // repay 0.25 WBTC
      await wbtc.connect(supplier).approve(cWBTC.address, '1000000000000000000000000000000000000000');
      await cWBTC.connect(supplier).repayBorrow('25000000');
    });

    expect(await cWBTC.totalBorrows()).to.be.lt(wbtcBorrowBalance);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail after tvl in market drops 90%', async () => {
    const ETH_BAL = hre.ethers.utils.parseEther('10000000000');
    await hre.network.provider.request({
      method: 'hardhat_setBalance',
      params: [LARGE_DAI_HOLDER, hre.ethers.utils.hexStripZeros(ETH_BAL.toHexString())],
    });

    const MINT_AMOUNT = ETH_BAL.sub(hre.ethers.utils.parseEther('1000'));
    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);
      await cETH.connect(supplier).mint({ value: MINT_AMOUNT });
    });

    // redeploy pool
    const factory = (await hre.ethers.getContractFactory(
      'AnteCompoundTVLTest',
      deployer
    )) as AnteCompoundTVLTest__factory;
    test = await factory.deploy();
    await test.deployed();

    await runAsSigner(LARGE_DAI_HOLDER, async () => {
      const supplier = await hre.ethers.getSigner(LARGE_DAI_HOLDER);
      await cETH.connect(supplier).redeem(await cETH.balanceOf(LARGE_DAI_HOLDER));
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
