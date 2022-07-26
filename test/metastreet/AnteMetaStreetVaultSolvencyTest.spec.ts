import hre from 'hardhat';
const { waffle } = hre;

import { AnteMetaStreetVaultSolvencyTest, AnteMetaStreetVaultSolvencyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteMetaStreetVaultSolvencyTest', function () {
  let test: AnteMetaStreetVaultSolvencyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    const factory = (await hre.ethers.getContractFactory(
      'AnteMetaStreetVaultSolvencyTest',
      deployer
    )) as AnteMetaStreetVaultSolvencyTest__factory;
    test = await factory.deploy('0x2542549517ee2dd58E550Db22a104A05035E5016');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
