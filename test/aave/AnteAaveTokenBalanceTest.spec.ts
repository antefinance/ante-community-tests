import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { AnteAaveTokenBalanceAbove15K, AnteAaveTokenBalanceAbove15K__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

// TODO replace 'YourAnteTest'
describe('AnteAaveTokenBalanceAbove15K', function () {
  let test: AnteAaveTokenBalanceAbove15K; // TODO replace
  let token: Contract;

  let globalSnapshotId: string;

  // TODO FILL IN WITH TEST PARAMETERS
  const tokenAddr = '0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9'; // TODO fill in
  const holderAddr = '0x25F2226B597E8F9514B3F68F00f494cF4f286491'; // TODO fill in
  const failThreshold = 15000; // TODO fill this in without decimal places (e.g. for 100 USDC, 100 instead of 100000000)

  const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

  let failThresholdWithDecimals: BigNumber;
  let startTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteAaveTokenBalanceAbove15K', // TODO replace this
      deployer
    )) as AnteAaveTokenBalanceAbove15K__factory; // TODO replace this
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
