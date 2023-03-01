import hre from 'hardhat';
const { waffle } = hre;

import {
  AllNetworksAnteBalancerV2TokenBalanceTest__factory,
  AllNetworksAnteBalancerV2TokenBalanceTest,
} from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AllNetworksAnteBalancerV2TokenBalanceTest', function () {
  let test: AllNetworksAnteBalancerV2TokenBalanceTest;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AllNetworksAnteBalancerV2TokenBalanceTest',
      deployer
    )) as AllNetworksAnteBalancerV2TokenBalanceTest__factory;
    test = await factory.deploy(
      '0xBA12222222228d8Ba445958a75a0704d566BF2C8', // balancerV2
      [
        '0x7F5c764cBc14f9669B88837ca1490cCa17c31607', // USDC
        '0x4200000000000000000000000000000000000006', // WETH
        '0x296F55F8Fb28E498B858d0BcDA06D955B2Cb3f97', // STG
        '0x68f180fcce6836688e9084f035309e29bf0a2095', // WBTC
        '0xda10009cbd5d07dd0cecc66161fc93d7c9000da1', // DAI
        '0x4200000000000000000000000000000000000042', // OP Optimism
      ]
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
