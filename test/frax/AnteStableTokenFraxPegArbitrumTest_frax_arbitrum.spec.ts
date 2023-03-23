import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenFraxPegArbitrumTest__factory, AnteStableTokenFraxPegArbitrumTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenFraxPegArbitrumTest', function () {
  let test: AnteStableTokenFraxPegArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenFraxPegArbitrumTest', deployer)) as AnteStableTokenFraxPegArbitrumTest__factory;
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
