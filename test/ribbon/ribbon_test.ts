import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

describe('AnteRibbonV2UpdatableThetaVaultPlungeTest', function () {
  let test: AnteRibbonV2UpdatableThetaVaultPlungeTest;

  let globalSnapshotId: string;

  let vaultAddr: string;
  let vaultAsset: string;
  let startTokenBalance: BigNumber[] = new Array(6);

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteRibbonV2UpdatableThetaVaultPlungeTest',
      deployer
    )) as AnteRibbonV2UpdatableThetaVaultPlungeTest__factory;
    test = await factory.deploy();
    await test.deployed();

    for (let i = 0; i < 4; i++) {
      vaultAddr = await test.thetaVaults(i);
      vaultAsset = await test.assets(i);
      startTokenBalance[i] = await test.calculateAssetBalance(vaultAddr, vaultAsset);
    }
    // manual for reth and aave vaults
    startTokenBalance[4] = await test.calculateAssetBalance(
      '0xA1Da0580FA96129E753D736a5901C31Df5eC5edf',
      '0xae78736Cd615f374D3085123A210448E74Fc6393'
    );
    startTokenBalance[5] = await test.calculateAssetBalance(
      '0xe63151A0Ed4e5fafdc951D877102cf0977Abd365',
      '0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9'
    );

    console.log('T-STETH-C vault balance:    ', startTokenBalance[0].toString());
    console.log('T-ETH-C vault balance:      ', startTokenBalance[1].toString());
    console.log('T-USDC-P-ETH vault balance: ', startTokenBalance[2].toString());
    console.log('T-WBTC-C vault balance:     ', startTokenBalance[3].toString());
    console.log('T-RETH-C vault balance:     ', startTokenBalance[4].toString());
    console.log('T-AAVE-C vault balance:     ', startTokenBalance[5].toString());
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass on deploy', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
});
