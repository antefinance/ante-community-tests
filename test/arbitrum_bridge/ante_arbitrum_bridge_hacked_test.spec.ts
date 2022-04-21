import hre from 'hardhat';
const { waffle } = hre;

import { AnteArbitrumBridgeHackedTest__factory, AnteArbitrumBridgeHackedTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteArbitrumBridgeHackedTest', function () {
  let test: AnteArbitrumBridgeHackedTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteArbitrumBridgeHackedTest',
      deployer
    )) as AnteArbitrumBridgeHackedTest__factory;
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
