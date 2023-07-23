import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteNexusMutualCapitalPoolTVLPlungeTest,
  AnteNexusMutualCapitalPoolTVLPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteNexusMutualCapitalPoolTVLPlungeTest', function () {
  let test: AnteNexusMutualCapitalPoolTVLPlungeTest;
  let steth: Contract;
  let dai: Contract;

  let globalSnapshotId: string;

  const NEXUS_MUTUAL_POOL = '0xcafea112Db32436c2390F5EC988f3aDB96870627';
  const stethAddr = '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84';
  const daiAddr = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4'; // throwaway

  let startETHBalance: BigNumber;
  let startSTETHBalance: BigNumber;
  let startDAIBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteNexusMutualCapitalPoolTVLPlungeTest',
      deployer
    )) as AnteNexusMutualCapitalPoolTVLPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get contracts
    steth = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', stethAddr, deployer);
    dai = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', daiAddr, deployer);
    
    // Get balances on deploy
    startETHBalance = await test.getETHBalance();
    startSTETHBalance = await test.getSTETHBalance();
    startDAIBalance = await test.getDAIBalance();

    console.log('ETH balance: ' + startETHBalance);
    console.log('stETH balance: ' + startSTETHBalance);
    console.log('DAI balance: ' + startDAIBalance);
    console.log('Current TVL (USD): ' + await test.getCurrentTVL());
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if TVL drops by 89%, should still pass', async () => {
    // transfer away 89% of pool funds
    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await NexusMutualPoolSigner.sendTransaction({
        to: targetAddr,
        value: startETHBalance.div(100).mul(89)
      });
    });

    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await steth.connect(NexusMutualPoolSigner).transfer(targetAddr, startSTETHBalance.div(100).mul(89));
    });

    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await dai.connect(NexusMutualPoolSigner).transfer(targetAddr, startDAIBalance.div(100).mul(89));
    });

    expect(await test.checkTestPasses()).to.be.true;


  });

  it('if TVL drops by 90%, should fail', async () => {
    // transfer away 1% of remaining funds to reach 90% transferred
    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await NexusMutualPoolSigner.sendTransaction({
        to: targetAddr,
        value: startETHBalance.div(100)
      });
    });

    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await steth.connect(NexusMutualPoolSigner).transfer(targetAddr, startSTETHBalance.div(100));
    });

    await runAsSigner(NEXUS_MUTUAL_POOL, async () => {
      const NexusMutualPoolSigner = await hre.ethers.getSigner(NEXUS_MUTUAL_POOL);
      await dai.connect(NexusMutualPoolSigner).transfer(targetAddr, startDAIBalance.div(100));
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
