import hre from 'hardhat';
const { waffle } = hre;

import { AnteEthDevRugTest__factory, AnteEthDevRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteETHDevRugTest', function () {
  let test: AnteEthDevRugTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory('AnteEthDevRugTest', deployer)) as AnteEthDevRugTest__factory;
    test = await factory.deploy('0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
