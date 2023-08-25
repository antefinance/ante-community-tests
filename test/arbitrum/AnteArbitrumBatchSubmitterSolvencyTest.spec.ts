import hre from 'hardhat';
const { waffle } = hre;

import { AnteArbitrumBatchSubmitterSolvencyTest__factory, AnteArbitrumBatchSubmitterSolvencyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteArbitrumBatchSubmitterSolvencyTest', function () {
  let test: AnteArbitrumBatchSubmitterSolvencyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteArbitrumBatchSubmitterSolvencyTest',
      deployer
    )) as AnteArbitrumBatchSubmitterSolvencyTest__factory;
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
