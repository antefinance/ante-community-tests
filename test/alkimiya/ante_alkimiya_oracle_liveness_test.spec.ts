import hre from 'hardhat';
const { waffle } = hre;

import { AnteAlkimiyaV1EthOracleLivenessTest, AnteAlkimiyaV1EthOracleLivenessTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe.only('AnteAlkimiyaV1EthOracleLivenessTest', function () {
  let test: AnteAlkimiyaV1EthOracleLivenessTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAlkimiyaV1EthOracleLivenessTest',
      deployer
    )) as AnteAlkimiyaV1EthOracleLivenessTest__factory;
    test = await factory.deploy('0x3CB3608bfF641b55F8DBaFe86AFC91Cd36a17185');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if advance 72 hrs, test should fail', async () => {
    // advance time 72 hrs and 1 block
    await evmIncreaseTime(259200);
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
