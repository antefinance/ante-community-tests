import hre from 'hardhat';
const { waffle } = hre;

import { MultiNetworkAnteBusdPegTest__factory, MultiNetworkAnteBusdPegTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

type DeploymentSetting = {
  busd: string;
  priceFeed: string;
};

type DeploymentSettings = Record<string, DeploymentSetting>;

describe('MultiNetworkAnteBusdPegTest', function () {
  let test: MultiNetworkAnteBusdPegTest;

  let globalSnapshotId: string;

  const deploymentSettings: DeploymentSettings = {
    mainnet: {
      busd: '0x4Fabb145d64652a948d72533023f6E7A623C7C53',
      priceFeed: '0x833d8eb16d306ed1fbb5d7a2e019e106b960965a',
    },
    optimisticEthereum: {
      busd: '0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39',
      priceFeed: '0xc1cb3b7cbb3e786ab85ea28489f332f4faed5bc4',
    },
  };

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    expect(deploymentSettings[process.env.NETWORK as string]).to.not.be.undefined;

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'MultiNetworkAnteBusdPegTest',
      deployer
    )) as MultiNetworkAnteBusdPegTest__factory;
    test = await factory.deploy(
      deploymentSettings[process.env.NETWORK as string].busd,
      deploymentSettings[process.env.NETWORK as string].priceFeed
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
