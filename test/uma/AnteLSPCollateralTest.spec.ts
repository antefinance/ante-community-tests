import hre from 'hardhat';
const { waffle } = hre;

import { AnteLSPCollateralTest, AnteLSPCollateralTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

// Uses Fox Token LSP as a testing condition
describe('AnteLSPCollateralTest', function () {
  let test: AnteLSPCollateralTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteLSPCollateralTest', deployer)) as AnteLSPCollateralTest__factory;
    test = await factory.deploy('0xE38f290eAC1f83A960c461100b0c7a231B9Cae16');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
