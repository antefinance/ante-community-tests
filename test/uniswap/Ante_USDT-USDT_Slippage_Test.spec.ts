import hre from 'hardhat';
const { waffle } = hre;

import { AnteUSDCUSDTPeg__factory, AnteUSDCUSDTPeg } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUSDCUSDTPeg', function () {
  let test: AnteUSDCUSDTPeg;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteUSDCUSDTPeg', deployer)) as AnteUSDCUSDTPeg__factory;
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
