import hre from 'hardhat';
const { waffle } = hre;

import { AnteTotalSupplyPlungeAaveArbitrumTest, AnteTotalSupplyPlungeAaveArbitrumTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteTotalSupplyPlungeAaveArbitrumTest AAVE Arbitrum', function () {
  let test: AnteTotalSupplyPlungeAaveArbitrumTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteTotalSupplyPlungeAaveArbitrumTest',
      deployer
    )) as AnteTotalSupplyPlungeAaveArbitrumTest__factory;
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
    expect(await test.testedContracts(4)).to.equal('0x625E7708f30cA75bfd92586e17077590C60eb4cD');
    await expect(test.testedContracts(5)).to.be.reverted;
  });

  it('thresholds are greater than 0', async () => {
    for (let i = 0; i < 5; i++) {
      expect(await test.thresholds(i)).to.be.gt(0);
    }
  });
});
