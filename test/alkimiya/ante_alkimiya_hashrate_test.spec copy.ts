import hre from 'hardhat';
const { waffle } = hre;

import { AnteAlkimiyaV1EthHashrateTest, AnteAlkimiyaV1EthHashrateTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';

describe.only('AnteAlkimiyaV1EthHashrateTest', function () {
  let test: AnteAlkimiyaV1EthHashrateTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteAlkimiyaV1EthHashrateTest',
      deployer
    )) as AnteAlkimiyaV1EthHashrateTest__factory;
    test = await factory.deploy('0x3CB3608bfF641b55F8DBaFe86AFC91Cd36a17185');
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
