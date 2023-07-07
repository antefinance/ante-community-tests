import hre from 'hardhat';
const { waffle } = hre;

import { AnteOptimismL1BridgeTokenSolvencyTest__factory, AnteOptimismL1BridgeTokenSolvencyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteOptimismL1BridgeTokenSolvencyTest', function () {
  let test: AnteOptimismL1BridgeTokenSolvencyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismL1BridgeTokenSolvencyTest',
      deployer
    )) as AnteOptimismL1BridgeTokenSolvencyTest__factory;
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
