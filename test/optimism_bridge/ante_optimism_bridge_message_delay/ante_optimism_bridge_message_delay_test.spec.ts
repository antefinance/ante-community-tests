import hre from 'hardhat';
const { waffle, ethers } = hre;

import {
  AnteOptimismMessageDelayTest__factory, AnteOptimismMessageDelayTest,
  FromL1ControlState__factory, FromL1ControlState,
  ICanonicalTransactionChain,
  L2CrossDomainMessenger__factory
} from '../../../typechain';
import AnteOptimismMessageDelayTestAbi from '../../../abi/contracts/optimism_bridge/AnteMessageDelayTest/AnteOptimismMessageDelayTest.sol/AnteOptimismMessageDelayTest.json'
import { evmSnapshot, evmRevert, blockTimestamp, runAsSigner, evmSetNextBlockTimestamp, fundSigner } from '../../helpers';
import { expect } from 'chai';
import { defaultAbiCoder } from 'ethers/lib/utils';
import config from '../../../hardhat.config';
import { HttpNetworkUserConfig } from 'hardhat/types';

/**
 * IMPORTANT! In order to run this testsuite, you have to edit AnteOptimismMessageDelayTest.sol:
 * - add to line 77:  || block.chainid == 31337
 * - add to line 51:  && block.chainid != 31337
 */
describe('AnteOptimismMessageDelayTest', function () {
  const [deployer] = waffle.provider.getWallets();
  const L1_CANONICAL_TRANSACTION_CHAIN = '0x5E4e65926BA27467555EB562121fac00D24E9dD2';
  const L1_CROSS_DOMAIN_MESSENGER_ADDRESS = '0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1';
  const L2_CROSS_DOMAIN_MESSENGER_ADDRESS = '0x4200000000000000000000000000000000000007';
  const L1ToL2Alias = '0x36bde71c97b33cc4729cf772ae268934f7ab70b2';

  let test: AnteOptimismMessageDelayTest;
  let l1Controller: FromL1ControlState;

  let globalSnapshotId: string;
  let snapshotId: string;

  before(async () => {
    await ethers.provider.send("hardhat_reset", [
      {
        forking: {
          jsonRpcUrl: (config.networks?.optimisticEthereum as HttpNetworkUserConfig)?.url,
          blockNumber: 86331460,
        },
      },
    ]);

    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismMessageDelayTest',
      deployer
    )) as AnteOptimismMessageDelayTest__factory;
    test = await factory.deploy();
    await test.deployed();

    await ethers.provider.send("hardhat_reset", [
      {
        forking: {
          jsonRpcUrl: (config.networks?.mainnet as HttpNetworkUserConfig)?.url,
          blockNumber: 16000000,
        },
      },
    ]);

    /** Deploy controller contract on L1 */
    const [l1Deployer] = waffle.provider.getWallets();
    const controllerFactory = (await hre.ethers.getContractFactory(
      'FromL1ControlState',
      l1Deployer
    )) as FromL1ControlState__factory;
    l1Controller = await controllerFactory.deploy(test.address);
    await l1Controller.deployed();


    /** @todo Need to switch back to L2 */
    snapshotId = await evmSnapshot();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  beforeEach(async () => {
    await evmRevert(snapshotId);
    snapshotId = await evmSnapshot();
  });

  describe('AnteOptimismMessageDelayTest', () => {
    it('should pass', async () => {
      expect(await test.checkTestPasses()).to.be.true;
    });

    describe('setTimestamp', () => {
      it('cannot be called by EOA', async () => {
        const state = defaultAbiCoder.encode(['address'], [deployer.address]);
        await expect(test.setTimestamp(state)).to.be.revertedWith('InvalidAddress');
      });

      it('can be called by Cross Domain Messenger', async () => {
        expect(await test.submittedTimestamps(deployer.address)).to.be.eq(0);

        await runAsSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS, async () => {
          const signer = await ethers.getSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);
          await fundSigner(signer.address);

          const submittedTimestamp = await blockTimestamp();
          const state = defaultAbiCoder.encode(['address', 'uint256'], [deployer.address, submittedTimestamp]);
          await test.connect(signer).setTimestamp(state);
          expect(await test.submittedTimestamps(deployer.address)).to.be.eq(submittedTimestamp);
        });
      });
    })

    it('should fail if more than 20 minutes passed until message is relayed', async () => {
      expect(await test.checkTestPasses()).to.be.true;

      await test.connect(deployer).setController(l1Controller.address);

      const L2CrossDomainMessenger = (await ethers.getContractFactory("L2CrossDomainMessenger")) as L2CrossDomainMessenger__factory;
      const l2CrossDomainMessenger = L2CrossDomainMessenger.attach(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);

      await runAsSigner(L1ToL2Alias, async () => {
        const signer = await ethers.getSigner(L1ToL2Alias);
        await fundSigner(signer.address);

        const submittedTimestamp = await blockTimestamp();
        const state = defaultAbiCoder.encode(['address', 'uint256'], [deployer.address, submittedTimestamp]);

        const anteTestInterface = new ethers.utils.Interface(AnteOptimismMessageDelayTestAbi);
        const message = anteTestInterface.encodeFunctionData('setTimestamp', [state]);

        await evmSetNextBlockTimestamp(submittedTimestamp + 21 * 60);

        await expect(
          l2CrossDomainMessenger.connect(signer).relayMessage(
            test.address,
            l1Controller.address,
            message,
            0
          )
        ).to.not.be.reverted;
      });

      const checkTestState = defaultAbiCoder.encode(['address'], [deployer.address]);

      await test.setStateAndCheckTestPasses(checkTestState);
      expect(await test.checkTestPasses()).to.be.false;
    });

    it('should pass if less than 20 minutes passed until message is relayed', async () => {
      expect(await test.checkTestPasses()).to.be.true;

      await runAsSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS, async () => {
        const signer = await ethers.getSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);
        await fundSigner(signer.address);

        const submittedTimestamp = await blockTimestamp();
        const state = defaultAbiCoder.encode(['address', 'uint256'], [deployer.address, submittedTimestamp]);

        await evmSetNextBlockTimestamp(submittedTimestamp + 19 * 60);
        await test.connect(signer).setTimestamp(state);
      });

      const checkTestState = defaultAbiCoder.encode(['address'], [deployer.address]);

      await test.setStateAndCheckTestPasses(checkTestState);
      expect(await test.checkTestPasses()).to.be.true;
    });
  });

  describe('FromL1ControlState', () => {
    it('enqueues the message in CTC', async () => {
      const canonicalTransacationChain = (await ethers.getContractAt("ICanonicalTransactionChain", L1_CANONICAL_TRANSACTION_CHAIN)) as ICanonicalTransactionChain;
      const initNumElements = await canonicalTransacationChain.getQueueLength();
      await expect(l1Controller.connect(deployer).sendState()).to.not.be.reverted;

      expect(await canonicalTransacationChain.getQueueLength()).to.be.eq(initNumElements + 1);
    });
  })
});
