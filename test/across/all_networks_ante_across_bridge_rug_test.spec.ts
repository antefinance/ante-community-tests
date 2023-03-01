import hre from 'hardhat';
const { waffle } = hre;

import {
  AllNetworksAnteAcrossOptimisticBridgeTest__factory,
  AllNetworksAnteAcrossOptimisticBridgeTest,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

type DeploymentSetting = {
  poolAddress: string;
  tokenAddresses: string[];
};

type DeploymentSettings = Record<string, DeploymentSetting>;

describe('AllNetworksAnteAcrossOptimisticBridgeTest', function () {
  let test: AllNetworksAnteAcrossOptimisticBridgeTest;

  let globalSnapshotId: string;

  const deploymentSettings: DeploymentSettings = {
    optimisticEthereum: {
      poolAddress: '0xa420b2d1c0841415A695b81E5B867BCD07Dff8C9',
      tokenAddresses: [
        '0x4200000000000000000000000000000000000006', // WETH
        '0x7F5c764cBc14f9669B88837ca1490cCa17c31607', // USDC
        '0x68f180fcCe6836688e9084f035309E29Bf0A2095', // WBTC
      ],
    },
    mainnet: {
      poolAddress: '0xc186fA914353c44b2E33eBE05f21846F1048bEda',
      tokenAddresses: [
        '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
        '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
        '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // WBTC
      ],
    },
  };

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    expect(deploymentSettings[process.env.NETWORK as string]).to.not.be.undefined;

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AllNetworksAnteAcrossOptimisticBridgeTest',
      deployer
    )) as AllNetworksAnteAcrossOptimisticBridgeTest__factory;
    test = await factory.deploy(
      deploymentSettings[process.env.NETWORK as string].poolAddress,
      deploymentSettings[process.env.NETWORK as string].tokenAddresses
    );
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
