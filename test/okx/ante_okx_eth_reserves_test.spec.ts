import hre from 'hardhat';
const { waffle } = hre;

import { AnteOKXEthReservesTest, AnteOKXEthReservesTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteOKXEthReservesTest', function () {
  let test: AnteOKXEthReservesTest;
  let usdt: Contract;
  let usdc: Contract;

  const USDT = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
  const USDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const USDK = '0x1c48f86ae57291F7686349F12601910BD8D470bb';
  const SHIB = '0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE';
  const USDP = '0x8E870D67F660D95d5be530380D0eC0bd388289E1';
  const TUSD = '0x0000000000085d4780B73119b644AE5ecd22b376';

  const ETH_USD_FEED = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
  const USDT_USD_FEED = '0x3E7d1eAB13ad0104d2750B8863b489D65364e32D';
  const USDC_USD_FEED = '0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6';
  const USDP_USD_FEED = '0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3';

  const OKX_7 = '0x5041ed759Dd4aFc3a72b8192C143F72f4724081A';
  const SIFU = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77';
  const VITALIK = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';
  const ANTE_POOL_FACTORY = '0xa03492A9A663F04c51684A3c172FC9c4D7E02eDc';

  let signer;
  let balance: BigNumber;
  let threshold: BigNumber;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteOKXEthReservesTest',
      deployer
    )) as AnteOKXEthReservesTest__factory;
    test = await factory.deploy();
    await test.deployed();

    usdt = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', USDT, deployer);
    usdc = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', USDC, deployer);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('non-owner cannot add reserve wallet', async () => {
    await fundSigner(SIFU);
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).addReserve(USDC, VITALIK)).to.be.revertedWith(
        'Ownable: caller is not the owner'
      );
    });
  });

  it('owner cannot add reserve for non-added token', async () => {
    await expect(test.addReserve(SHIB, SIFU)).to.be.revertedWith('Token not added yet, use addToken');
  });

  it('owner cannot add reserve with 0 balance of token', async () => {
    await expect(test.addReserve(USDK, SIFU)).to.be.revertedWith('No token balance in wallet!');
  });

  it('owner can add a reserve wallet', async () => {
    await expect(test.addReserve(USDC, VITALIK)).not.reverted;
  });

  it('owner cannot add a duplicate reserve wallet', async () => {
    await expect(test.addReserve(USDC, VITALIK)).to.be.revertedWith('Token/wallet already checked');
  });

  // TODO owner cannot add more than max # of wallets for a given token

  it('non-owner cannot add token', async () => {
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).addToken(TUSD, ETH_USD_FEED, SIFU)).to.be.revertedWith(
        'Ownable: caller is not the owner'
      );
    });
  });

  it('owner cannot add token that is already supported', async () => {
    await expect(test.addToken(USDC, ETH_USD_FEED, SIFU)).to.be.revertedWith(
      'Token already checked, use addReserve instead!'
    );
  });

  it('owner cannot add token that is not a contract', async () => {
    await expect(test.addToken(VITALIK, ETH_USD_FEED, SIFU)).to.be.revertedWith('Non-contract token address!');
  });

  it('owner cannot add token if wallet provided has 0 balance', async () => {
    await expect(test.addToken(SHIB, ETH_USD_FEED, SIFU)).to.be.revertedWith('No token balance in wallet!');
  });

  it('owner cannot add token if price feed does not return positive price', async () => {
    await expect(test.addToken(SHIB, ANTE_POOL_FACTORY, VITALIK)).to.be.revertedWith('Invalid feed!');
  });

  it('owner can add token/wallet', async () => {
    await expect(test.addToken(USDP, USDP_USD_FEED, OKX_7)).not.reverted;

    // get current reserves for later
    let response = await test.getCurrentReserves();
    balance = response.totalReserves;
    console.log('total reserves: ', balance.toString());
    let usdtBal = await usdt.balanceOf(OKX_7);
    console.log('usdt available: ', usdtBal.div(1e6).toString());

    threshold = balance.sub(usdtBal.div(1e6)).add(1000);
    console.log('new threshold:  ', threshold.toString());
  });

  // TODO owner cannot add more than max # of tokens

  it('cannot execute price feed update if none pending', async () => {
    await expect(test.executeUpdatePriceFeed()).to.be.revertedWith('No update pending!');
  });

  it('non-owner cannot commit price feed update', async () => {
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).commitUpdatePriceFeed(USDC, USDT_USD_FEED)).to.be.revertedWith(
        'Ownable: caller is not the owner'
      );
    });
  });

  it('cannot commit price feed update for unsupported token', async () => {
    await expect(test.commitUpdatePriceFeed(SHIB, USDT_USD_FEED)).to.be.revertedWith(
      'Token not added yet, use addToken'
    );
  });

  it('cannot commit price feed update for address that is not a contract', async () => {
    await expect(test.commitUpdatePriceFeed(USDC, SIFU)).to.be.revertedWith('Non-contract address!');
  });

  it('cannot commit price feed update if new feed does not return positive price', async () => {
    await expect(test.commitUpdatePriceFeed(USDC, ANTE_POOL_FACTORY)).to.be.revertedWith('Invalid feed!');
  });

  it('cannot execute failure threshold update if none pending', async () => {
    await expect(test.executeUpdateFailureThreshold()).to.be.revertedWith('No update pending!');
  });

  it('non-owner cannot commit failure threshold update', async () => {
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).commitUpdateFailureThreshold(0)).to.be.revertedWith(
        'Ownable: caller is not the owner'
      );
    });
  });

  it('cannot commit failure threshold update if new threshold would fail', async () => {
    await expect(test.commitUpdateFailureThreshold(BigNumber.from('5000000000'))).to.be.revertedWith(
      'Test would fail proposed threshold!'
    );
  });

  it('cannot execute price feed update before waiting period over', async () => {
    await test.commitUpdatePriceFeed(USDC, USDT_USD_FEED);
    evmIncreaseTime(3600);
    evmMineBlocks(1);
    await expect(test.executeUpdatePriceFeed()).to.be.revertedWith('Need to wait 1 day to update price feed!');
  });

  it('cannot commit another price feed update during waiting period', async () => {
    await expect(test.commitUpdatePriceFeed(USDC, USDC_USD_FEED)).to.be.revertedWith('Another update already pending!');
  });

  it('cannot execute failure threshold update before waiting period over', async () => {
    await test.commitUpdateFailureThreshold(threshold);
    evmIncreaseTime(3600);
    evmMineBlocks(1);
    await expect(test.executeUpdateFailureThreshold()).to.be.revertedWith(
      'Need to wait 7 days to adjust failure threshold!'
    );
  });

  it('cannot commit another failure threshold update during waiting period', async () => {
    await expect(test.commitUpdateFailureThreshold(BigNumber.from('20000000'))).to.be.revertedWith(
      'Another update already pending!'
    );
  });

  it('non-owner can execute price feed update after waiting period', async () => {
    evmIncreaseTime(79200);
    evmMineBlocks(1);
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).executeUpdatePriceFeed()).not.reverted;
    });
  });

  it('non-owner can execute failure threshold update after waiting period', async () => {
    evmIncreaseTime(525600);
    evmMineBlocks(1);
    await runAsSigner(SIFU, async () => {
      signer = await hre.ethers.getSigner(SIFU);
      await expect(test.connect(signer).executeUpdateFailureThreshold()).not.reverted;
    });
  });

  it('test still passes', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if reserves fall just above threshold, test still passes', async () => {
    let delta = balance.sub(threshold);
    console.log('max to transfer:', delta.toString());
    let usdtBal = await usdt.balanceOf(OKX_7);
    console.log('usdt in wallet: ', usdtBal.toString());

    // transfer away balance
    await fundSigner(OKX_7);
    await runAsSigner(OKX_7, async () => {
      signer = await hre.ethers.getSigner(OKX_7);
      await usdt.connect(signer).transfer(SIFU, delta.mul(1e6).sub(1));
    });

    expect(await test.checkTestPasses()).to.be.true;
  });

  // TODO fix this unit test
  it('if reserves fall below threshold, test should fail', async () => {
    console.log(
      'this next unit test will fail because we passed enough time running the other tests that the oracles are considered stale and the test auto-passes. You can check it by commenting out line 147 in the contract to bypass the price feed staleness check'
    );
    // transfer away balance
    let usdtBal = await usdt.balanceOf(OKX_7);
    console.log('remaining usdt in wallet: ', usdtBal.toString());
    await runAsSigner(OKX_7, async () => {
      signer = await hre.ethers.getSigner(OKX_7);
      await usdt.connect(signer).transfer(SIFU, usdtBal);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
