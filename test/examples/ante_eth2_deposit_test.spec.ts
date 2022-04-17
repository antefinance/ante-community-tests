import hre from 'hardhat';
const { waffle } = hre;

import { AnteETH2DepositTest__factory, AnteETH2DepositTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteETH2DepositTest', function () {
  let test: AnteETH2DepositTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteETH2DepositTest',
      deployer
    )) as AnteETH2DepositTest__factory;
    test = await factory.deploy('0x00000000219ab540356cBB839Cbe05303d7705Fa');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
