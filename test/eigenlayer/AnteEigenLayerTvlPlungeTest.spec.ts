import hre from 'hardhat';
const { waffle } = hre;

import { AnteEigenLayerTvlPlungeTest, AnteEigenLayerTvlPlungeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

const EL_cbETH_STRATEGY_ADDR = '0x54945180dB7943c0ed0FEE7EdaB2Bd24620256bc';
const EL_stETH_STRATEGY_ADDR = '0x93c4b944D05dfe6df7645A86cd2206016c51564D';
const EL_rETH_STRATEGY_ADDR = '0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2';
const CBETH_TOKEN_ADDR = '0xBe9895146f7AF43049ca1c1AE358B0541Ea49704';
const STETH_TOKEN_ADDR = '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84';
const RETH_TOKEN_ADDR = '0xae78736Cd615f374D3085123A210448E74Fc6393';

const PERCENT_REDUCTION_TH = 90;

const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

let cbETHFailThreshold: BigNumber;
let stETHFailThreshold: BigNumber;
let rETHFailThreshold: BigNumber;
let cbETHStartTokenBalance: BigNumber;
let stETHStartTokenBalance: BigNumber;
let rETHStartTokenBalance: BigNumber;

describe('AnteEigenLayerTvlPlungeTest', function () {
  let test: AnteEigenLayerTvlPlungeTest;
  let token: Contract;

  let globalSnapshotId: string;

  
  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteEigenLayerTvlPlungeTest',
      deployer
    )) as AnteEigenLayerTvlPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // get starting balances
    token = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', CBETH_TOKEN_ADDR, deployer);
    cbETHStartTokenBalance = await token.balanceOf(EL_cbETH_STRATEGY_ADDR);
    console.log('cbETHStartTokenBalance = ' + cbETHStartTokenBalance);
    token = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', STETH_TOKEN_ADDR, deployer);
    stETHStartTokenBalance = await token.balanceOf(EL_stETH_STRATEGY_ADDR);
    console.log('stETHStartTokenBalance = ' + stETHStartTokenBalance);
    token = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', RETH_TOKEN_ADDR, deployer);
    rETHStartTokenBalance = await token.balanceOf(EL_rETH_STRATEGY_ADDR);
    console.log('rETHStartTokenBalance = ' + rETHStartTokenBalance);

    // calculate failure thresholds
    cbETHFailThreshold = BigNumber.from(cbETHStartTokenBalance)
      .mul(BigNumber.from(PERCENT_REDUCTION_TH))
      .div(BigNumber.from(100));
    console.log('cbETHFailThreshold = ' + cbETHFailThreshold);
    stETHFailThreshold = BigNumber.from(stETHStartTokenBalance)
      .mul(BigNumber.from(PERCENT_REDUCTION_TH))
      .div(BigNumber.from(100));
      console.log('stETHFailThreshold = ' + stETHFailThreshold);
    rETHFailThreshold = BigNumber.from(rETHStartTokenBalance)
      .mul(BigNumber.from(PERCENT_REDUCTION_TH))
      .div(BigNumber.from(100));
      console.log('rETHFailThreshold = ' + rETHFailThreshold);

      console.log(cbETHStartTokenBalance.sub(cbETHFailThreshold).add(1));

  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if cbETH token balance drops under -90%, should fail', async () => {
    // transfer away enough to meet failure condition
    await fundSigner(EL_cbETH_STRATEGY_ADDR);
    await runAsSigner(EL_cbETH_STRATEGY_ADDR, async () => {
      const holderSigner = await hre.ethers.getSigner(EL_cbETH_STRATEGY_ADDR);
      await token.connect(holderSigner).transfer(sifuAddr, cbETHStartTokenBalance.sub(cbETHFailThreshold).add(1));
    });

    expect(await test.checkTestPasses()).to.be.false;
  });

});
