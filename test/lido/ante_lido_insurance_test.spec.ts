import hre from 'hardhat';
const { waffle } = hre;

import { AnteLidoInsuranceTest, AnteLidoInsuranceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('LidoInsuranceTest', function () {
  let test: AnteLidoInsuranceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteLidoInsuranceTest',
      deployer
    )) as AnteLidoInsuranceTest__factory;
    test = await factory.deploy(
      '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84',
      '0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c'
    );
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
