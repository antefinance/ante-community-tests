import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteAlkimiyaV2BTCOracleLivenessTestAvax,
  AnteAlkimiyaV2BTCOracleLivenessTestAvax__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe.only('AnteAlkimiyaV2BTCOracleLivenessTest', function () {
  let test: AnteAlkimiyaV2BTCOracleLivenessTestAvax;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAlkimiyaV2BTCOracleLivenessTest',
      deployer
    )) as AnteAlkimiyaV2BTCOracleLivenessTestAvax__factory;
    test = await factory.deploy('0x444a5880EbDaaaa14F942b6F71b39ffe8d4cEF93');
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
