import hre from 'hardhat';
const { waffle } = hre;

import { AnteImpossibleMultisigIDIATest, AnteImpossibleMultisigIDIATest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe.only('AnteImpossibleMultisigIDIATest', function () {
  let test: AnteImpossibleMultisigIDIATest;
  let idia: Contract;

  let globalSnapshotId: string;

  const idiaAddr = '0x0b15ddf19d47e6a86a56148fb4afffc6929bcb89';
  const impossibleMultisig1 = '0x782CB1bC68C949a88f153e2eFc120CC7754E402B';
  const impossibleMultisig2 = '0xC86217A218996359680D89D242a4EAC93fC607a9';
  const targetAddr = '0x1A2B73207C883Ce8E51653d6A9cC8a022740cCA4';
  const FIVE_MILLION = BigNumber.from('5000000000000000000000000');

  let startIDIABalance1: BigNumber;
  let startIDIABalance2: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteImpossibleMultisigIDIATest',
      deployer
    )) as AnteImpossibleMultisigIDIATest__factory;
    test = await factory.deploy();
    await test.deployed();

    // Get balances on deploy
    idia = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', idiaAddr, deployer);
    startIDIABalance1 = await idia.balanceOf(impossibleMultisig1);
    startIDIABalance2 = await idia.balanceOf(impossibleMultisig2);
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass on deploy', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if IDIA balance drops to 10M, should still pass', async () => {
    // transfer away all but 5M tokens per multisig (10M total)
    await fundSigner(impossibleMultisig1);
    await runAsSigner(impossibleMultisig1, async () => {
      const impossibleMultisig1Signer = await hre.ethers.getSigner(impossibleMultisig1);
      await idia.connect(impossibleMultisig1Signer).transfer(targetAddr, startIDIABalance1.sub(FIVE_MILLION));
    });

    await fundSigner(impossibleMultisig2);
    await runAsSigner(impossibleMultisig2, async () => {
      const impossibleMultisig2Signer = await hre.ethers.getSigner(impossibleMultisig2);
      await idia.connect(impossibleMultisig2Signer).transfer(targetAddr, startIDIABalance2.sub(FIVE_MILLION));
    });

    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if IDIA balance drops below 10M, should fail', async () => {
    // transfer away 1 token (total should be 10M-1)
    await runAsSigner(impossibleMultisig1, async () => {
      const impossibleMultisig1Signer = await hre.ethers.getSigner(impossibleMultisig1);
      await idia.connect(impossibleMultisig1Signer).transfer(targetAddr, 1);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
