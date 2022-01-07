import hre from 'hardhat';
const { waffle } = hre;

import { AnteUMACollateralTest__factory, AnteUMACollateralTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUMACollateralTest', function () {
  let test: AnteUMACollateralTest;

  let globalSnapshotId: string;

  const _umaLspAddr = [
    // https://projects.umaproject.org/0xfd7Ead07dF3cD2543fE269d9E320376c64D9143E
    '0xfd7Ead07dF3cD2543fE269d9E320376c64D9143E',
    // https://projects.umaproject.org/0x57C891D01605d456bBEa535c8E56EaAc4E2DFE11
    '0x57C891D01605d456bBEa535c8E56EaAc4E2DFE11',
  ];

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteUMACollateralTest',
      deployer,
    )) as AnteUMACollateralTest__factory;
    test = await factory.deploy(_umaLspAddr);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});