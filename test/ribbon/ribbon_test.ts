import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
  AnteRibbonV2ThetaVaultPlungeTest,
  AnteRibbonV2ThetaVaultPlungeTest__factory,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';
import { HardhatNetworkForkingConfig } from 'hardhat/types';

describe('AnteRibbonV2UpdatableThetaVaultPlungeTest', function () {
  let forking = hre.config.networks.hardhat.forking! as HardhatNetworkForkingConfig;
  let test: AnteRibbonV2UpdatableThetaVaultPlungeTest;
  let oldTest: AnteRibbonV2ThetaVaultPlungeTest;
  let globalSnapshotId: string;

  let vaultAddr: string;
  let vaultAsset: string;
  let startTokenBalance: BigNumber[] = new Array(6);

  let oldStartTokenBalance: BigNumber[] = new Array(2);
  let oldAssets = [
    '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
    '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // WBTC
  ];
  before(async () => {
    globalSnapshotId = await evmSnapshot();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  const blocksToTest = [16046014, 16046015, 16046018, 16046077, 16046413];
  blocksToTest.forEach((block: number) => {
    describe(`In block ${block}`, () => {
      before(async function () {
        forking.blockNumber = block;
        console.log(`Forking to block ${block}`);
        await hre.network.provider.request({
          method: 'hardhat_reset',
          params: [
            {
              forking: {
                jsonRpcUrl: forking.url,
                blockNumber: block,
              },
            },
          ],
        });

        console.log(`deploying contracts...`);

        const [deployer] = waffle.provider.getWallets();
        const factory = (await hre.ethers.getContractFactory(
          'AnteRibbonV2UpdatableThetaVaultPlungeTest',
          deployer
        )) as AnteRibbonV2UpdatableThetaVaultPlungeTest__factory;
        test = await factory.deploy();
        await test.deployed();

        oldTest = await hre.ethers.getContractAt(
          'AnteRibbonV2ThetaVaultPlungeTest',
          '0x82793d0AF8cb6A12B2fdAcfE02b718460467F0c3'
        );
        await oldTest.deployed();
      });

      it('Previous Ribbon Test Should Pass?', async () => {
        for (let i = 0; i < 2; i++) {
          vaultAddr = await oldTest.thetaVaults(i);
          vaultAsset = oldAssets[i];
          oldStartTokenBalance[i] = await oldTest.calculateAssetBalance(vaultAddr);
        }
        console.log('OLD T-ETH-C vault balance:  ', oldStartTokenBalance[0].toString());
        console.log('OLD T-WBTC-C vault balance: ', oldStartTokenBalance[1].toString());
        expect(await oldTest.checkTestPasses()).to.be.true;
      });

      it('Updated Ribbon Test Should Pass', async () => {
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
        expect(await test.checkTestPasses()).to.be.true;
      });
    });
  });
});
