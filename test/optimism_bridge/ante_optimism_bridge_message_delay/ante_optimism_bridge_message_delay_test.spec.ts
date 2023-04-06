import hre from 'hardhat';
const { waffle, ethers } = hre;
import net, { Server } from 'net';
import chalk from 'chalk';
import {
  AnteOptimismMessageDelayTest__factory, AnteOptimismMessageDelayTest,
  FromL1ControlState__factory, FromL1ControlState,
  ICanonicalTransactionChain,
  L2CrossDomainMessenger__factory
} from '../../../typechain';
import AnteOptimismMessageDelayTestAbi from '../../../abi/contracts/optimism_bridge/AnteMessageDelayTest/AnteOptimismMessageDelayTest.sol/AnteOptimismMessageDelayTest.json'
import { evmSnapshot, evmRevert, blockTimestamp, evmSetNextBlockTimestamp, runAsSignerProvider, providerFundSigner } from '../../helpers';
import { expect } from 'chai';
import { defaultAbiCoder } from 'ethers/lib/utils';
import config from '../../../hardhat.config';
import { HttpNetworkUserConfig } from 'hardhat/types';
import { providers, Wallet } from 'ethers';

/**
 * IMPORTANT! In order to run this testsuite, you have to edit AnteOptimismMessageDelayTest.sol:
 * - add to line 71:  || block.chainid == 31337
 * 
 * AND
 * 
 * Run a local fork of Optimism on http://localhost:8545
 * E.g.: npx hardhat node --fork https://opt-mainnet.g.alchemy.com/v2/<key> --fork-block-number 86331460
 */
describe('AnteOptimismMessageDelayTest', function () {
  const L1_CANONICAL_TRANSACTION_CHAIN = '0x5E4e65926BA27467555EB562121fac00D24E9dD2';
  const L2_CROSS_DOMAIN_MESSENGER_ADDRESS = '0x4200000000000000000000000000000000000007';
  const L1ToL2Alias = '0x36bde71c97b33cc4729cf772ae268934f7ab70b2';

  let test: AnteOptimismMessageDelayTest;
  let l1Controller: FromL1ControlState;

  let l1GlobalSnapshotId: string;
  let l1SnapshotId: string;
  let l2GlobalSnapshotId: string;
  let l2SnapshotId: string;

  let l2Provider = new ethers.providers.JsonRpcProvider('http://localhost:8545');
  let l1Deployer: Wallet;
  let l2Deployer: Wallet;

  before(async function () {
    if (!await isForkRunning(l2Provider)) {
      console.warn(chalk.yellow('AnteOptimismMessageDelayTest: This test suite requires a local fork to run on http://localhost:8545 in order to execute'))
      this.skip();
    }

    await l2Provider.send("hardhat_reset", [
      {
        forking: {
          jsonRpcUrl: (config.networks?.optimisticEthereum as HttpNetworkUserConfig)?.url,
          blockNumber: 86331460,
        },
      },
    ]);

    l1GlobalSnapshotId = await evmSnapshot();
    l2GlobalSnapshotId = await l2Provider.send('evm_snapshot', []);

    l2Deployer = new ethers.Wallet("0x526d54c21663f5c1baf8755ed5cf5c5b2e5e5c5be2d796da3ce3aa57da38f85c", l2Provider);
    await providerFundSigner(l2Provider, l2Deployer.address);
    const factory = (await hre.ethers.getContractFactory(
      'AnteOptimismMessageDelayTest',
      l2Deployer
    )) as AnteOptimismMessageDelayTest__factory;
    test = await factory.connect(l2Deployer).deploy();
    await test.deployed();

    // Ensure hardhat network is set to L1 (Eth mainnet)
    await ethers.provider.send("hardhat_reset", [
      {
        forking: {
          jsonRpcUrl: (config.networks?.mainnet as HttpNetworkUserConfig)?.url,
          blockNumber: 16000000,
        },
      },
    ]);

    /** Deploy controller contract on L1 */
    l1Deployer = waffle.provider.getWallets()[0];
    const controllerFactory = (await hre.ethers.getContractFactory(
      'FromL1ControlState',
      l1Deployer
    )) as FromL1ControlState__factory;
    l1Controller = await controllerFactory.deploy(test.address);
    await l1Controller.deployed();

    l1SnapshotId = await evmSnapshot();
    l2SnapshotId = await l2Provider.send('evm_snapshot', []);
  });

  after(async () => {
    if (!await isForkRunning(l2Provider)) {
      return;
    }
    await evmRevert(l1GlobalSnapshotId);
    await l2Provider.send('evm_revert', [l2GlobalSnapshotId]);
  });

  beforeEach(async () => {
    await evmRevert(l1SnapshotId);
    await l2Provider.send('evm_revert', [l2SnapshotId]);
    l1SnapshotId = await evmSnapshot();
    l2SnapshotId = await l2Provider.send('evm_snapshot', []);
  });

  describe('AnteOptimismMessageDelayTest', () => {
    it('should pass', async () => {
      expect(await test.checkTestPasses()).to.be.true;
    });

    describe('setTimestamp', () => {
      it('cannot be called by EOA', async () => {
        const state = defaultAbiCoder.encode(['address'], [l2Deployer.address]);
        await expect(test.setTimestamp(state)).to.be.revertedWith('InvalidAddress');
      });

      it('cannot be called from a L1 contract other than the preset controller', async () => {
        expect(await test.submittedTimestamps(l2Deployer.address)).to.be.eq(0);

        await runAsSignerProvider(l2Provider, L1ToL2Alias, async () => {
          const signer = l2Provider.getSigner(L1ToL2Alias);
          await providerFundSigner(l2Provider, await signer.getAddress());

          const submittedTimestamp = await blockTimestamp();
          const state = defaultAbiCoder.encode(['address', 'uint256'], [l2Deployer.address, submittedTimestamp]);
          await expect(test.connect(signer).setTimestamp(state)).to.be.revertedWith(
            'InvalidAddress'
          );
        });
      });
    })

    it('should fail if more than 20 minutes passed until message is relayed', async () => {
      expect(await test.checkTestPasses()).to.be.true;

      await test.connect(l2Deployer).setController(l1Controller.address);

      const L2CrossDomainMessenger = (await ethers.getContractFactory("L2CrossDomainMessenger", l2Deployer)) as L2CrossDomainMessenger__factory;
      const l2CrossDomainMessenger = L2CrossDomainMessenger.attach(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);

      await runAsSignerProvider(l2Provider, L1ToL2Alias, async () => {
        const signer = l2Provider.getSigner(L1ToL2Alias);
        await providerFundSigner(l2Provider, await signer.getAddress());

        const submittedTimestamp = await blockTimestamp();
        const state = defaultAbiCoder.encode(['address', 'uint256'], [l2Deployer.address, submittedTimestamp]);

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

      const checkTestState = defaultAbiCoder.encode(['address'], [l2Deployer.address]);

      await test.setStateAndCheckTestPasses(checkTestState);
      expect(await test.checkTestPasses()).to.be.false;
    });

    it('should pass if less than 20 minutes passed until message is relayed', async () => {
      expect(await test.checkTestPasses()).to.be.true;

      const L2CrossDomainMessenger = (await ethers.getContractFactory("L2CrossDomainMessenger", l2Deployer)) as L2CrossDomainMessenger__factory;
      const l2CrossDomainMessenger = L2CrossDomainMessenger.attach(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);

      await runAsSignerProvider(l2Provider, L1ToL2Alias, async () => {
        const signer = l2Provider.getSigner(L1ToL2Alias);
        await providerFundSigner(l2Provider, await signer.getAddress());

        const submittedTimestamp = await blockTimestamp();
        const state = defaultAbiCoder.encode(['address', 'uint256'], [l2Deployer.address, submittedTimestamp]);

        await evmSetNextBlockTimestamp(submittedTimestamp + 19 * 60);

        const anteTestInterface = new ethers.utils.Interface(AnteOptimismMessageDelayTestAbi);
        const message = anteTestInterface.encodeFunctionData('setTimestamp', [state]);

        await expect(
          l2CrossDomainMessenger.connect(signer).relayMessage(
            test.address,
            l1Controller.address,
            message,
            0
          )
        ).to.not.be.reverted;
      });

      const checkTestState = defaultAbiCoder.encode(['address'], [l2Deployer.address]);

      await test.setStateAndCheckTestPasses(checkTestState);
      expect(await test.checkTestPasses()).to.be.true;
    });
  });

  describe('FromL1ControlState', () => {
    it('enqueues the message in CTC', async () => {
      const canonicalTransacationChain = (await ethers.getContractAt("ICanonicalTransactionChain", L1_CANONICAL_TRANSACTION_CHAIN)) as ICanonicalTransactionChain;
      const initNumElements = await canonicalTransacationChain.getQueueLength();
      await expect(l1Controller.connect(l1Deployer).sendState()).to.not.be.reverted;

      expect(await canonicalTransacationChain.getQueueLength()).to.be.eq(initNumElements + 1);
    });
  })
});

const isForkRunning = async (provider: providers.JsonRpcProvider): Promise<boolean> => {
  try {
    return (await provider.getBlock('latest'))?.number > 0;
  } catch (e) {
    return false;
  }
}