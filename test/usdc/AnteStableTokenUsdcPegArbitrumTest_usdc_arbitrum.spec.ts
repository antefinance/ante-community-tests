import hre from 'hardhat';
const { waffle } = hre;

import { AnteStableTokenUsdcPegArbitrumTest__factory, AnteStableTokenUsdcPegArbitrumTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteStableTokenUsdcPegArbitrumTest', function () {
  let test: AnteStableTokenUsdcPegArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteStableTokenUsdcPegArbitrumTest', deployer)) as AnteStableTokenUsdcPegArbitrumTest__factory;
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
