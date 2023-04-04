import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteOptimismMessageDelayTest__factory, AnteOptimismMessageDelayTest,
  FromL1ControlState__factory, FromL1ControlState
} from '../../../typechain';

import { evmSnapshot, evmRevert, blockTimestamp, evmSetNextBlockTimestamp, runAsSigner } from '../../helpers';
import { expect } from 'chai';
import { defaultAbiCoder } from 'ethers/lib/utils';
import { MockProvider } from 'ethereum-waffle';
import config from '../../../hardhat.config';

describe('AnteOptimismMessageDelayTest', function () {
  const [deployer] = waffle.provider.getWallets();
  const CROSS_DOMAIN_MESSENGER_ADDRESS = '0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1';

  let test: AnteOptimismMessageDelayTest;
  let controller: FromL1ControlState;

  let globalSnapshotId: string;

  before(async () => {
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
        expect(await test.setTimestamp(state)).to.be.revertedWith('OnlyMessenger');
      });

      it('can be called by Cross Domain Messenger', async () => {
        const submittedTimestamp = await blockTimestamp();
        expect(await test.submittedTimestamps(deployer.address)).to.be.eq(0);

        await runAsSigner(CROSS_DOMAIN_MESSENGER_ADDRESS, async () => {
          const state = defaultAbiCoder.encode(['address', 'uint256'], [deployer.address, submittedTimestamp]);
          await test.setTimestamp(state);
          expect(await test.submittedTimestamps(deployer.address)).to.be.eq(submittedTimestamp);
        });
      });
    })
  });
});
