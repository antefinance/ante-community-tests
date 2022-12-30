import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { 
    AntePoHBridgeTest, 
    AntePoHBridgeTest__factory,
    WETH,
    WETH__factory,
    TokenBridge,
    TokenBridge__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AntePoHBridgeTest', function () {
  let test: AntePoHBridgeTest;
  let token: WETH;
  let bridge: TokenBridge;

  let globalSnapshotId: string;

  const sifuAddr = '0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77'; // used as throwaway address to transfer tokens

  let failThresholdWithDecimals: BigNumber;
  let startTokenBalance: BigNumber;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy the WETH token
    const wethFactory = (await hre.ethers.getContractFactory('WETH', deployer)) as WETH__factory;
    token = await wethFactory.deploy();
    await token.deployed();

    // Deploy the Token Bridge
    const tokenBridgeFactory = (await hre.ethers.getContractFactory('TokenBridge', deployer)) as TokenBridge__factory;
    bridge = await tokenBridgeFactory.deploy(token.address);
    await bridge.deployed();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoHBridgeTest', deployer)) as AntePoHBridgeTest__factory;
    test = await factory.deploy(bridge.address);
    await test.deployed();

    // Set up the test and bridge
    await token.setOwner(bridge.address);
    await bridge.setAnteTest(test.address);
    await bridge.enable();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass and bridge is enabled', async () => {
    await test.checkTestPasses();
    expect(await test.callStatic.checkTestPasses()).to.be.true;
    expect(await bridge.heartbeat()).to.be.true;
  });

  it('should fail and disable the bridge', async () => {
    await test.setPreImage("123456");
    await test.checkTestPasses();
    expect(await test.callStatic.checkTestPasses()).to.be.false;
    expect(await bridge.heartbeat()).to.be.false;
  })
});
