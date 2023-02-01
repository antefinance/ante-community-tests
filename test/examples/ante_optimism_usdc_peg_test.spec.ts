import hre from 'hardhat';
const { waffle } = hre;

import { AnteOptimismUSDCPegTest, AnteOptimismUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteArbitrumUSDCPegTest', function () {
  if (process.env.NETWORK != 'optimism') return;

  let test: AnteOptimismUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismUSDCPegTest',
      deployer
    )) as AnteOptimismUSDCPegTest__factory;
    test = await factory.deploy('0x7F5c764cBc14f9669B88837ca1490cCa17c31607');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
