import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteAlkimiyaV2EthOracleLivenessTestAvax,
  AnteAlkimiyaV2EthOracleLivenessTestAvax__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe.only('AnteAlkimiyaV2EthOracleLivenessTest', function () {
  let test: AnteAlkimiyaV2EthOracleLivenessTestAvax;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAlkimiyaV2EthOracleLivenessTest',
      deployer
    )) as AnteAlkimiyaV2EthOracleLivenessTestAvax__factory;
    test = await factory.deploy('0xEfEacDD1008a9887cC26469D54D07b3aA87501cC');
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
