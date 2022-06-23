import hre from 'hardhat';
const { waffle } = hre;

import { AnteChainlinkUpdateTimeTest, AnteChainlinkUpdateTimeTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteChainlinkUpdateTimeTest', function () {
  let test: AnteChainlinkUpdateTimeTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteChainlinkUpdateTimeTest',
      deployer
    )) as AnteChainlinkUpdateTimeTest__factory;
    test = await factory.deploy([
      '0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A',
      '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419',
    ]);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
