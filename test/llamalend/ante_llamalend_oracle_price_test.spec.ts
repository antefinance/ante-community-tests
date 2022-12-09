import hre from 'hardhat';
const { waffle } = hre;

import { AnteLlamaLendOraclePriceTest, AnteLlamaLendOraclePriceTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { Contract, BigNumber } from 'ethers';

describe('AnteLlamaLendOraclePriceTest', function () {
  let test: AnteLlamaLendOraclePriceTest;
  let pool: Contract;
  const tubbyLoanAddr = '0x34d0A4B1265619F3cAa97608B621a17531c5626f';

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    pool = await hre.ethers.getContractAt(
      'contracts/llamalend/llamalend-contracts/LendingPool.sol:LendingPool',
      tubbyLoanAddr,
      deployer
    );

    const factory = (await hre.ethers.getContractFactory(
      'AnteLlamaLendOraclePriceTest',
      deployer
    )) as AnteLlamaLendOraclePriceTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if passing in valid message with high price', async () => {
    console.log(
      'This next unit test is expected to revert. See test script for details on how to modify the contract code to check this condition.'
    );
    // Unfortunately, hardhat uses chainid 31337 so the hash calculated by the
    // test on the forked chain ends up different than it would be on mainnet.
    // On the other hand, we can't spoof a signed message by the oracle on the
    // hardhat "chain" without knowing the oracle's private key. So, we work
    // around it by changing 2 things in the AnteLlamaLendOraclePriceTest.sol
    // contract:
    // 1. Choose an existing message that will be the "failing" message, e.g.
    //    https://tx.eth.samczsun.com/ethereum/0xdec8265c7dcbe6168b4d10f8179c8b6884f96a817bca30654487733ee0f6a585
    // 2. On line 36, set failure threshold lower than the price in the
    //    message, e.g. 4e16 for the example
    // 3. On line 109, replace block.chainid with bytes(1)
    // 4. If you chose a different message to check, update the arguments below
    //
    // For a more generalized LlamaLend price oracle ante test, you could have
    // the test script deploy a LlamaLend lending pool, deploy an Ante Test
    // checking that lending pool, set the oracle to the waffle deployer, sign
    // a message with a price greater than the failure threshold, set test
    // state, and check that the test fails appropriately.

    await test.setMessageToCheck(
      BigNumber.from('45690000000000000'), //price
      1669858244, //deadline
      27, // v
      '0x57a44d4d5578295c0b40c13a6def46b2d28d5f1887c385bf38f1dbc29b64c8fc', //r
      '0x1b68ffc82e99e9a943e9cc1e1eaf3538726045976c9be0957aea87ecac2fe5ae' //s
    );

    expect(await test.checkTestPasses()).to.be.false;
  });
});
