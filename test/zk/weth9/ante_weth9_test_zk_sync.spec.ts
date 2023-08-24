import hre from 'hardhat';

import { AnteWETH9TestZkSync } from '../../../typechain';

import { expect } from 'chai';
import { Wallet, Provider } from 'zksync-web3';
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';
import { HttpNetworkUserConfig } from 'hardhat/types';

const RICH_WALLET_PK =
  '0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110';

async function deployTest(deployer: Deployer): Promise<AnteWETH9TestZkSync> {
  try {
    const artifact = await deployer.loadArtifact('AnteWETH9TestZkSync');
    return <AnteWETH9TestZkSync>await deployer.deploy(artifact, ['0x5AEa5775959fBC2557Cc8789bC1bf90A239D9a91']);
  } catch (error) {
    console.error(error);
    throw new Error('Error deploying contract');
  }
}

describe('AnteWETH9TestZkSync', function () {
  let deployer: Deployer;
  let test: AnteWETH9TestZkSync;

  let globalSnapshotId: string;
  let zkProvider: Provider;

  before(async () => {
    zkProvider = new Provider((hre.network.config as HttpNetworkUserConfig).url);
    zkProvider.send('evm_snapshot', []);

    deployer = new Deployer(hre, new Wallet(RICH_WALLET_PK));

    test = await deployTest(deployer);
  });

  after(async () => {
    zkProvider.send('evm_revert', [globalSnapshotId])
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
