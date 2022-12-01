import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
  AnteRibbonV2ThetaVaultPlungeTest,
  AnteRibbonV2ThetaVaultPlungeTest__factory,
  IRibbonThetaVault,
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner, evmIncreaseTime, evmMineBlocks } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { HardhatNetworkForkingConfig } from 'hardhat/types';

describe('AnteRibbonV2UpdatableThetaVaultPlungeTest', function () {
  let forking = hre.config.networks.hardhat.forking! as HardhatNetworkForkingConfig;
  let test: AnteRibbonV2UpdatableThetaVaultPlungeTest;
  let oldTest: AnteRibbonV2ThetaVaultPlungeTest;
  let globalSnapshotId: string;

  let vaultAddr: string;
  let vaultAsset: string;
  let vault: Contract;
  let wstethAsSteth: BigNumber;
  let wsteth: Contract;
  let wstethBalance: BigNumber;
  let steth: Contract;
  let stethBalance: BigNumber;
  let weth: Contract;
  let wethBalance: BigNumber;
  let startTokenBalance: BigNumber[] = new Array(4);
  let vaultTotalBalance: BigNumber[] = new Array(4);

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

  const blocksToTest = [
    //16046013, 16046014, 16046015, 16046018, 16046077,
    16046137, 16046138, 16046412, 16046413,
  ];
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

      /*
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
      */

      it('Updated Ribbon Test Should Pass', async () => {
        for (let i = 0; i < 4; i++) {
          vaultAddr = await test.thetaVaults(i);
          vaultAsset = await test.assets(vaultAddr);
          startTokenBalance[i] = await test.calculateAssetBalance(vaultAddr);
          vault = await hre.ethers.getContractAt(
            'contracts/ribbon/ribbon-v2-contracts/interfaces/IRibbonThetaVault.sol:IRibbonThetaVault',
            vaultAddr
          );
          vaultTotalBalance[i] = await vault.totalBalance();
          if (i == 0) {
            wsteth = await hre.ethers.getContractAt(
              'contracts/ribbon/ribbon-v2-contracts/interfaces/ISTETH.sol:IWSTETH',
              '0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0'
            );
            wstethBalance = await wsteth.balanceOf(vaultAddr);
            steth = await hre.ethers.getContractAt(
              'contracts/ribbon/ribbon-v2-contracts/interfaces/ISTETH.sol:ISTETH',
              '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84'
            );
            stethBalance = await steth.balanceOf(vaultAddr);
            weth = await hre.ethers.getContractAt(
              'contracts/interfaces/IERC20.sol:IERC20',
              '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
            );
            wethBalance = await weth.balanceOf(vaultAddr);
            wstethAsSteth = await wsteth.getStETHByWstETH(wstethBalance);
          }
        }

        console.log('T-STETH-C test balance:     ', startTokenBalance[0].toString());
        console.log('T-STETH-C wstETH balance:   ', wstethBalance.toString());
        console.log('T-STETH-C wstETH -> stETH:  ', wstethAsSteth.toString());
        console.log('T-STETH-C stETH balance:    ', stethBalance.toString());
        console.log('T-STETH-C WETH balance:     ', wethBalance.toString());
        console.log('T-STETH-C vault balance:    ', vaultTotalBalance[0].toString());
        //console.log('T-USDC-P-ETH test balance:  ', startTokenBalance[1].toString());
        //console.log('T-USDC-P-ETH vault balance: ', vaultTotalBalance[1].toString());
        //console.log('T-ETH-C test balance:       ', startTokenBalance[2].toString());
        //console.log('T-ETH-C vault balance:      ', vaultTotalBalance[2].toString());
        //console.log('T-WBTC-C test balance:      ', startTokenBalance[3].toString());
        //console.log('T-WBTC-C vault balance:     ', vaultTotalBalance[3].toString());
        expect(await test.checkTestPasses()).to.be.true;
      });
    });
  });
});
