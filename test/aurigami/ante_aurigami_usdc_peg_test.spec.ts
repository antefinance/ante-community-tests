import hre from 'hardhat';
const { waffle } = hre;

import { AnteAurigamiUSDCPegTest, AnteAurigamiUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAurigamiUSDCPegTest', function () {
  let test: AnteAurigamiUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAurigamiUSDCPegTest',
      deployer
    )) as AnteAurigamiUSDCPegTest__factory;
    test = await factory.deploy('0x4f0d864b1ABf4B701799a0b30b57A22dFEB5917b');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
