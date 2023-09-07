import hre from 'hardhat';
const { waffle } = hre;

import { AnteCurvestEthwEthPoolTest,AnteCurvestEthwEthPoolTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteCurvestEthwEthPoolTest', function () {
  let test: AnteCurvestEthwEthPoolTest;

  let globalSnapshotId: string;

  const POOL_ADDRESS = '0x828b154032950C8ff7CF8085D841723Db2696056';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4'; // throwaway
  const stETHAddr = '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84';
  const wETHAddr = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';

  let startBalanceST: BigNumber;
  let startBalanceW: BigNumber;
  let stETH: Contract;
  let wETH: Contract;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCurvestEthwEthPoolTest',
      deployer
    )) as AnteCurvestEthwEthPoolTest__factory;
    test = await factory.deploy();
    await test.deployed();

    startBalanceST = await test.getBalanceST();
    startBalanceW = await test.getBalanceW();

    stETH = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', stETHAddr, deployer);
    wETH = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', wETHAddr, deployer);

  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should pass when stETH balance drops 89%', async () => {
    await fundSigner(POOL_ADDRESS);
    await runAsSigner(POOL_ADDRESS, async () => {
      const PoolSigner = await hre.ethers.getSigner(POOL_ADDRESS);
      await stETH.connect(PoolSigner).transfer(targetAddr, startBalanceST.div(100).mul(89));
    });
    
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail when stETH balance drops 91%', async () => {
    await runAsSigner(POOL_ADDRESS, async () => {
      const PoolSigner = await hre.ethers.getSigner(POOL_ADDRESS);
      await stETH.connect(PoolSigner).transfer(targetAddr, startBalanceST.div(100).mul(2));
    });
    
    expect(await test.checkTestPasses()).to.be.false;
  });

  it('should pass when wETH balance drops 89%', async () => {
    //revert stETH balance
    await runAsSigner(targetAddr, async () => {
      const TargetSigner = await hre.ethers.getSigner(targetAddr);
      await stETH.connect(TargetSigner).transfer(POOL_ADDRESS, startBalanceST.div(100).mul(91));
    });
  
    await runAsSigner(POOL_ADDRESS, async () => {
      const PoolSigner = await hre.ethers.getSigner(POOL_ADDRESS);
      await wETH.connect(PoolSigner).transfer(targetAddr, startBalanceW.div(100).mul(89));
    });
    
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail when wETH balance drops 91%', async () => {
    await runAsSigner(POOL_ADDRESS, async () => {
      const PoolSigner = await hre.ethers.getSigner(POOL_ADDRESS);
      await wETH.connect(PoolSigner).transfer(targetAddr, startBalanceW.div(100).mul(2));
    });
    
    expect(await test.checkTestPasses()).to.be.false;
  });

});
