import hre from 'hardhat';
const { waffle } = hre;

import { AnteWBTCSupplyTest__factory, AnteWBTCSupplyTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteWBTCSupplyTest', function () {
  let test: AnteWBTCSupplyTest;

  const wBTCAddr = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599';
  const protocolName = 'WBTC';

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteWBTCSupplyTest',
      deployer
    )) as AnteWBTCSupplyTest__factory;
    test = await factory.deploy('0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should set protocol name properly', async () => {
    expect(await test.protocolName()).to.equal(protocolName);
  });

  it('should set testedContracts correctly', async () => {
    expect(await test.getTestedContracts()).to.deep.equal([wBTCAddr]);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
