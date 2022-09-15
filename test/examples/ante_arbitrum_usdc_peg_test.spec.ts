import hre from 'hardhat';
const { waffle } = hre;

import { AnteArbitrumUSDCPegTest, AnteArbitrumUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteArbitrumUSDCPegTest', function () {
  let test: AnteArbitrumUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteArbitrumUSDCPegTest',
      deployer
    )) as AnteArbitrumUSDCPegTest__factory;
    test = await factory.deploy('0xff970a61a04b1ca14834a43f5de4533ebddb5cc8');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
