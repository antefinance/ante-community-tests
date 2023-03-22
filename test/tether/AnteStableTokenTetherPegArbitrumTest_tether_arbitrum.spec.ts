import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenTetherPegArbitrumTest__factory, AnteStableTokenTetherPegArbitrumTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenTetherPegArbitrumTest', function () {
  let test: AnteStableTokenTetherPegArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenTetherPegArbitrumTest', deployer)) as AnteStableTokenTetherPegArbitrumTest__factory;
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
