import hre from 'hardhat';
const { waffle } = hre;

import { AnteAvaxUSDCPegTest, AnteAvaxUSDCPegTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAvaxUSDCPegTest', function () {
  if (process.env.NETWORK != 'avalanche') return;

  let test: AnteAvaxUSDCPegTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAvaxUSDCPegTest',
      deployer
    )) as AnteAvaxUSDCPegTest__factory;
    test = await factory.deploy('0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
