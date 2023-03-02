import hre from 'hardhat';
const { waffle } = hre;

import { AnteUDCGoerliTotalSupplyDropTest, AnteUDCGoerliTotalSupplyDropTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteUDCGoerliTotalSupplyDropTest USDC Goerli', function () {
  let test: AnteUDCGoerliTotalSupplyDropTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteUDCGoerliTotalSupplyDropTest',
      deployer
    )) as AnteUDCGoerliTotalSupplyDropTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should test 5 contracts', async () => {
    expect(await test.testedContracts(0)).to.equal('0x07865c6E87B9F70255377e024ace6630C1Eaa37F');
    await expect(test.testedContracts(1)).to.be.reverted;
  });

  it('thresholds are greater than 0', async () => {
    for (let i = 0; i < 1; i++) {
      expect(await test.thresholds(i)).to.be.gt(0);
    }
  });
});
