import hre from 'hardhat';
const { waffle } = hre;

import { AntePolygonUSDCPegTest, AntePolygonUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AntePolygonUSDCPegTest', function () {
  let test: AntePolygonUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AntePolygonUSDCPegTest',
      deployer
    )) as AntePolygonUSDCPegTest__factory;
    test = await factory.deploy('0x2791bca1f2de4661ed88a30c99a7a9449aa84174');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
