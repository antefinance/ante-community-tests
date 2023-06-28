import hre from 'hardhat';
const { waffle } = hre;

// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { AnteUniswapTokenBalanceAbove10M, AnteUniswapTokenBalanceAbove10M__factory } from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AnteUniswapTokenBalanceAbove10M', function () {
  let test: AnteUniswapTokenBalanceAbove10M;
  let token: Contract;

  let globalSnapshotId: string;

  const tokenAddr = '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984';
  const holderAddr = '0x1a9C8182C09F50C8318d769245beA52c32BE35BC';
  const failThreshold = 10*(10**6);

  const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

  let failThresholdWithDecimals: BigNumber;
  let startTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory(
      'AnteUniswapTokenBalanceAbove10M',
      deployer
    )) as AnteUniswapTokenBalanceAbove10M__factory;
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

  it('if token balance drops under 10M, should fail', async () => {
    // transfer away enough to meet failure condition
    await fundSigner(holderAddr);
    await runAsSigner(holderAddr, async () => {
      const holderSigner = await hre.ethers.getSigner(holderAddr);
      await token.connect(holderSigner).transfer(sifuAddr, startTokenBalance.sub(failThresholdWithDecimals).add(1));
    });

    expect(await test.checkTestPasses()).to.be.false;
  });
});
