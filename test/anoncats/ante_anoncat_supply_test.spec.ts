import hre from 'hardhat';
const { waffle } = hre;

import { AnteAnoncatOverpopulationTest, AnteAnoncatOverpopulationTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteAnoncatOverpopulationTest', function () {
  let test: AnteAnoncatOverpopulationTest;
  let token: Contract;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteAnoncatOverpopulationTest',
      deployer
    )) as AnteAnoncatOverpopulationTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  // TODO test negative case (if total supply over 100, test should fail)
});
