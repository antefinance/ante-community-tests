import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { AntePoHTest, AntePoHTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AntePoHTest', function () {
  let test: AntePoHTest;
  let token: Contract;

  let globalSnapshotId: string;

  const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

  let failThresholdWithDecimals: BigNumber;
  let startTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoHTest', deployer)) as AntePoHTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
