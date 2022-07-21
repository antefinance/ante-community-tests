import hre from 'hardhat';
const { waffle } = hre;

import { AnteEthMerge2023Test, AnteEthMerge2023Test__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmSetNextBlockTimestamp, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe.only('AnteEthMerge2023Test', function () {
  let test: AnteEthMerge2023Test;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteEthMerge2023Test',
      deployer
    )) as AnteEthMerge2023Test__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if block difficulty > 2**64 in 2022, should pass', async () => {
    // TODO increase block difficulty
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if 2023 and block difficulty < 2**64 and > 0, should fail', async () => {
    // TODO decrease block difficulty
    await evmSetNextBlockTimestamp(1672531200);
    await evmMineBlocks(1);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
