import hre from 'hardhat';
const { waffle, ethers } = hre;

import { GMXRugPullTest, GMXRugPullTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('GMXRugPullTest', function () {
  let test: GMXRugPullTest;

  let globalSnapshotId: string;
  let gmxVaultAddress = '0x489ee077994B6658eAfA855C308275EAd8097C4A'; // GMX Vault Address Arbitrum

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('GMXRugPullTest', deployer)) as GMXRugPullTest__factory;
    test = await factory.deploy(gmxVaultAddress, { gasLimit: 8000000 });
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    // test initial state
    expect(await test.checkTestPasses()).to.be.true;

    let stateAbiEncoded = ethers.utils.defaultAbiCoder.encode(['bool'], [true]);
    await test.setStateAndCheckTestPasses(stateAbiEncoded);

    expect(await test.checkTestPasses()).to.be.true;
  });
});
