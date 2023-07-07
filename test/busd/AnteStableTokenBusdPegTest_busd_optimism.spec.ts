import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenBusdPegTest__factory, AnteStableTokenBusdPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenBusdPegTest', function () {
  let test: AnteStableTokenBusdPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenBusdPegTest', deployer)) as AnteStableTokenBusdPegTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
