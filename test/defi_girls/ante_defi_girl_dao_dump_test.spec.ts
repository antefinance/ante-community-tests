import hre from 'hardhat';
const { waffle } = hre;

import { IERC721, AnteDeFiGirlDAODumpTest, AnteDeFiGirlDAODumpTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmSetNextBlockTimestamp, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe('AnteDeFiGirlDAODumpTest', function () {
  let test: AnteDeFiGirlDAODumpTest;
  let dfgirl: IERC721;

  let globalSnapshotId: string;

  const defigirldaoAddr = '0x754bbb703EEada12A6988c0e548306299A263a08';
  const dfgirlAddr = '0x3B14d194c8CF46402beB9820dc218A15e7B0A38f';
  const targetAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77';

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    dfgirl = await hre.ethers.getContractAt('IERC721', dfgirlAddr);

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteDeFiGirlDAODumpTest',
      deployer
    )) as AnteDeFiGirlDAODumpTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if DFGIRL balance drops below 780, should fail', async () => {
    // transfer away 1 DFGIRL
    await fundSigner(defigirldaoAddr);
    await runAsSigner(defigirldaoAddr, async () => {
      const deFiGirlDAOSigner = await hre.ethers.getSigner(defigirldaoAddr);
      await dfgirl.connect(deFiGirlDAOSigner).transferFrom(defigirldaoAddr, targetAddr, 5969);
    });

    expect(await test.checkTestPasses()).to.be.false;
  });

  it('if after 2023-09-01 and balance below 780, should pass', async () => {
    await evmSetNextBlockTimestamp(1693526400); // 2023-09-01 00:00:00 UTC
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.true;
  });
});
