import hre from 'hardhat';
const { waffle } = hre;

import { AnteAlUSDSupplyTest__factory, AnteAlUSDSupplyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('Ante_alUSDSupplyTest', function () {
  let test: AnteAlUSDSupplyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'Ante_alUSDSupplyTest',
      deployer
    )) as AnteAlUSDSupplyTest__factory;
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
