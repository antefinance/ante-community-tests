import hre from 'hardhat';
const { waffle } = hre;

import { AnteSPELLSupplyTest__factory, AnteSPELLSupplyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteSPELLSupplyTest', function () {
  if (process.env.NETWORK != 'avalanche') return;
  let test: AnteSPELLSupplyTest;

  const SPELLAddr = '0x090185f2135308BaD17527004364eBcC2D37e5F6';
  const protocolName = 'SPELL';

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteSPELLSupplyTest',
      deployer
    )) as AnteSPELLSupplyTest__factory;
    test = await factory.deploy('0x090185f2135308BaD17527004364eBcC2D37e5F6');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should set protocol name properly', async () => {
    expect(await test.protocolName()).to.equal(protocolName);
  });

  it('should set testedContracts correctly', async () => {
    expect(await test.getTestedContracts()).to.deep.equal([SPELLAddr]);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
