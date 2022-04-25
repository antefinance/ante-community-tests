import hre from 'hardhat';
const { waffle } = hre;

import { AnteCompoundcUSDCSupplyTest, AnteCompoundcUSDCSupplyTest__factory } from '../typechain';
import { evmSnapshot, evmRevert } from './helpers';
import { expect } from 'chai';

describe.only('AnteCompoundcUSDSupplyTest', function () {
  let test: AnteCompoundcUSDCSupplyTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteCompoundcUSDCSupplyTest',
      deployer
    )) as AnteCompoundcUSDCSupplyTest__factory;

    test = await factory.deploy('0x39aa39c021dfbae8fac545936693ac917d5e7563');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
