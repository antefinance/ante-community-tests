import hre from 'hardhat';
const { waffle } = hre;

import {
  AnteRibbonV2UpdatableThetaVaultPlungeTest,
  AnteRibbonV2UpdatableThetaVaultPlungeTest__factory,
  AnteRibbonV2ThetaVaultPlungeTest,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { HardhatNetworkForkingConfig } from 'hardhat/types';

describe('AnteRibbonV2UpdatableThetaVaultPlungeTest', function () {
  let forking = hre.config.networks.hardhat.forking! as HardhatNetworkForkingConfig;
  let globalSnapshotId: string;

  let oldTest: AnteRibbonV2ThetaVaultPlungeTest;
  let newTest: AnteRibbonV2UpdatableThetaVaultPlungeTest;

  let vaultAddr: string;
  let vault: Contract;
  let ribbonVaultBalance: BigNumber[] = new Array(6);
  let oldTestVaultBalance: BigNumber[] = new Array(2);
  let newTestVaultBalance: BigNumber[] = new Array(6);

  before(async () => {
    globalSnapshotId = await evmSnapshot();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  const blocksToTest = [16046013, 16046014, 16046138, 16046301, 16046338, 16046413];
  blocksToTest.forEach((block: number) => {
    describe(`In block ${block}`, () => {
      before(async function () {
        forking.blockNumber = block;
        //console.log(`Forking to block ${block}`);
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

        //console.log(`deploying contracts...`);

        const [deployer] = waffle.provider.getWallets();
        const factory = (await hre.ethers.getContractFactory(
          'AnteRibbonV2UpdatableThetaVaultPlungeTest',
          deployer
        )) as AnteRibbonV2UpdatableThetaVaultPlungeTest__factory;
        newTest = await factory.deploy();
        await newTest.deployed();

        oldTest = await hre.ethers.getContractAt(
          'AnteRibbonV2ThetaVaultPlungeTest',
          '0x82793d0AF8cb6A12B2fdAcfE02b718460467F0c3'
        );

        for (let i = 0; i < 4; i++) {
          vaultAddr = await newTest.thetaVaults(i);
          vault = await hre.ethers.getContractAt(
            'contracts/ribbon/ribbon-v2-contracts/vaults/BaseVaults/base/RibbonVault.sol:RibbonVault',
            vaultAddr
          );
          ribbonVaultBalance[i] = await vault.totalBalance();
        }
        vault = await hre.ethers.getContractAt(
          'contracts/ribbon/ribbon-v2-contracts/vaults/BaseVaults/base/RibbonVault.sol:RibbonVault',
          '0xA1Da0580FA96129E753D736a5901C31Df5eC5edf'
        );
        ribbonVaultBalance[4] = await vault.totalBalance();
        vault = await hre.ethers.getContractAt(
          'contracts/ribbon/ribbon-v2-contracts/vaults/BaseVaults/base/RibbonVault.sol:RibbonVault',
          '0xe63151A0Ed4e5fafdc951D877102cf0977Abd365'
        );
        ribbonVaultBalance[5] = await vault.totalBalance();

        console.log('Ribbon Vault internal balances');
        console.log('\tT-STETH-C totalBalance:    ', ribbonVaultBalance[0].toString());
        console.log('\tT-USDC-P-ETH totalBalance: ', ribbonVaultBalance[1].toString());
        console.log('\tT-ETH-C totalBalance:      ', ribbonVaultBalance[2].toString());
        console.log('\tT-WBTC-C totalBalance:     ', ribbonVaultBalance[3].toString());
        //console.log('\tT-RETH-C totalBalance:     ', ribbonVaultBalance[4].toString());
        //console.log('\tT-AAVE-C totalBalance:     ', ribbonVaultBalance[5].toString());
      });

      it('Previous Ribbon Test should pass?', async () => {
        for (let i = 0; i < 2; i++) {
          vaultAddr = await oldTest.thetaVaults(i);
          oldTestVaultBalance[i] = await oldTest.calculateAssetBalance(vaultAddr);
        }
        console.log('\tOLD T-ETH-C vault balance:  ', oldTestVaultBalance[0].toString());
        console.log('\tOLD T-WBTC-C vault balance: ', oldTestVaultBalance[1].toString());
        expect(await oldTest.checkTestPasses()).to.be.true;
      });

      it('Updated Ribbon Test should pass', async () => {
        for (let i = 0; i < 4; i++) {
          vaultAddr = await newTest.thetaVaults(i);
          newTestVaultBalance[i] = await newTest.calculateVaultBalance(vaultAddr);
        }
        // manual for reth and aave vaults
        /*
        newTestVaultBalance[4] = await newTest.calculateVaultBalance(
          '0xA1Da0580FA96129E753D736a5901C31Df5eC5edf',
          '0xae78736Cd615f374D3085123A210448E74Fc6393'
        );
        newTestVaultBalance[5] = await newTest.calculateVaultBalance(
          '0xe63151A0Ed4e5fafdc951D877102cf0977Abd365',
          '0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9'
        );
        */

        console.log('\tT-STETH-C vault balance:    ', newTestVaultBalance[0].toString());
        console.log('\tT-USDC-P-ETH vault balance: ', newTestVaultBalance[1].toString());
        console.log('\tT-ETH-C vault balance:      ', newTestVaultBalance[2].toString());
        console.log('\tT-WBTC-C vault balance:     ', newTestVaultBalance[3].toString());
        //console.log('T-RETH-C vault balance:     ', newTestVaultBalance[4].toString());
        //console.log('T-AAVE-C vault balance:     ', newTestVaultBalance[5].toString());
        expect(await newTest.checkTestPasses()).to.be.true;
      });
    });
  });
});
