import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { VitalikBalance, VitalikBalance__factory } from '../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from './helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

// TODO replace 'YourAnteTest'
describe('VitalikBalance', function () {
  let test: VitalikBalance; // TODO replace
  let token: Contract;

  let globalSnapshotId: string;

  // TODO FILL IN WITH TEST PARAMETERS
  const tokenAddr = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'; // TODO fill in
  const holderAddr = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'; // TODO fill in
  const failThreshold = 1; // TODO fill this in without decimal places (e.g. for 100 USDC, 100 instead of 100000000)

  const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

  let failThresholdWithDecimals: BigNumber;
  let startTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'VitalikBalance', // TODO replace this
      deployer
    )) as VitalikBalance__factory; // TODO replace this
    test = await factory.deploy();
    await test.deployed();

    // get starting balance
    token = await hre.ethers.getContractAt('contracts/interfaces/IERC20.sol:IERC20', tokenAddr, deployer);
    startTokenBalance = await token.balanceOf(holderAddr);

    // calculate failure threshold including decimals
    const decimals = await token.decimals();
    failThresholdWithDecimals = BigNumber.from(failThreshold).mul(BigNumber.from(10).pow(decimals));
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('if token balance drops under [AMOUNT], should fail', async () => {
    // transfer away enough to meet failure condition
    await fundSigner(holderAddr);
    await runAsSigner(holderAddr, async () => {
      const holderSigner = await hre.ethers.getSigner(holderAddr);
      await token.connect(holderSigner).transfer(sifuAddr, startTokenBalance.sub(failThresholdWithDecimals).add(1));
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
