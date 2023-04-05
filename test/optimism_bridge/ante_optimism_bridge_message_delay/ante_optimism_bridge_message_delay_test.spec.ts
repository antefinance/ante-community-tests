import hre from 'hardhat';
const { waffle, ethers } = hre;

import {
  AnteOptimismMessageDelayTest__factory, AnteOptimismMessageDelayTest,
  FromL1ControlState__factory, FromL1ControlState,
  L2CrossDomainMessenger__factory
} from '../../../typechain';
import AnteOptimismMessageDelayTestAbi from '../../../abi/contracts/optimism_bridge/AnteMessageDelayTest/AnteOptimismMessageDelayTest.sol/AnteOptimismMessageDelayTest.json';

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
  const L1_CROSS_DOMAIN_MESSENGER_ADDRESS = '0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1';
  const L2_CROSS_DOMAIN_MESSENGER_ADDRESS = '0x4200000000000000000000000000000000000007';

  let test: AnteOptimismMessageDelayTest;
  let controller: FromL1ControlState;

  let globalSnapshotId: string;

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

    const controllerFactory = (await hre.ethers.getContractFactory(
      'FromL1ControlState',
      deployer
    )) as FromL1ControlState__factory;
    controller = await controllerFactory.deploy(test.address);
    await controller.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
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

      const L2CrossDomainMessenger = (await ethers.getContractFactory("L2CrossDomainMessenger")) as L2CrossDomainMessenger__factory;
      const l2CrossDomainMessenger = L2CrossDomainMessenger.attach(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);

      const submittedTimestamp = await blockTimestamp();
      const state = defaultAbiCoder.encode(
        ['address', 'uint256'],
        [deployer.address, submittedTimestamp]
      );

      const anteTestInterface = new ethers.utils.Interface(AnteOptimismMessageDelayTestAbi);
      const message = anteTestInterface.encodeFunctionData('setTimestamp', [state]);

      await runAsSigner('0x0000000000000000000000000000000000000000', async () => {
        const signer = await ethers.getSigner('0x0000000000000000000000000000000000000000');
        await fundSigner(signer.address);

        await evmSetNextBlockTimestamp(submittedTimestamp + 21 * 60);
        // await test.connect(signer).setTimestamp(state);

        await l2CrossDomainMessenger.connect(signer).relayMessage(
          test.address,
          // L1 OptimismMessengerWrapper
          '0xa45DF1A388049fb8d76E72D350d24E2C3F7aEBd1',
          message,
          0
        );
      });

      // await runAsSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS, async () => {
      //   const signer = await ethers.getSigner(L2_CROSS_DOMAIN_MESSENGER_ADDRESS);
      //   await fundSigner(signer.address);

      //   const submittedTimestamp = await blockTimestamp();
      //   const state = defaultAbiCoder.encode(['address', 'uint256'], [deployer.address, submittedTimestamp]);

      //   await evmSetNextBlockTimestamp(submittedTimestamp + 21 * 60);
      //   await test.connect(signer).setTimestamp(state);
      // });

      // const checkTestState = defaultAbiCoder.encode(['address'], [deployer.address]);

      // expect(await test.setStateAndCheckTestPasses(checkTestState)).to.be.false;
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

      expect(await test.setStateAndCheckTestPasses(checkTestState)).to.be.true;
    });
  });
});
