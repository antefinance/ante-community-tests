import hre from 'hardhat';
const { waffle } = hre;

import { AnteInstadappTreasuryBalanceTest, AnteInstadappTreasuryBalanceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteInstadappTreasuryBalanceTest', function () {
  let test: AnteInstadappTreasuryBalanceTest;
  let inst: Contract;

  const treasuryAddr = '0x28849D2b63fA8D361e5fc15cB8aBB13019884d09';
  const tokenAddr = '0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4'; // throwaway

  let treasuryBalance: BigNumber;
  let thresholdBalance: BigNumber;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteInstadappTreasuryBalanceTest',
      deployer
    )) as AnteInstadappTreasuryBalanceTest__factory;
    test = await factory.deploy();
    await test.deployed();

    inst = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', tokenAddr, deployer);

    treasuryBalance = await test.getTreasuryBalance();
    thresholdBalance = await test.getThresholdBalance();

    console.log('Instadapp Treasury Balance: ' + treasuryBalance);
    console.log('threshold balance: ' + thresholdBalance);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if Treasury INST balance drops below 2M, should fail', async () => {
    // transfer away pool funds
    await fundSigner(treasuryAddr);
    await runAsSigner(treasuryAddr, async () => {
      const InstadappPoolSigner = await hre.ethers.getSigner(treasuryAddr);
      await inst.connect(InstadappPoolSigner).transfer(
        targetAddr, treasuryBalance.sub(thresholdBalance).add(1)
      );
    });
  });
});
