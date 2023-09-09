import hre from 'hardhat';
const { waffle } = hre;

import { AnteSablierProtocolFeeTest, AnteSablierProtocolFeeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteSablierProtocolFeeTest', function () {
  let test: AnteSablierProtocolFeeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteSablierProtocolFeeTest',
      deployer
    )) as AnteSablierProtocolFeeTest__factory;
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
