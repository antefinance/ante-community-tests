import hre from 'hardhat';
const { waffle } = hre;

import { AevoL1BridgeTokenSolvencyTest__factory, AevoL1BridgeTokenSolvencyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AevoL1BridgeTokenSolvencyTest', function () {
  let test: AevoL1BridgeTokenSolvencyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AevoL1BridgeTokenSolvencyTest',
      deployer
    )) as AevoL1BridgeTokenSolvencyTest__factory;
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
