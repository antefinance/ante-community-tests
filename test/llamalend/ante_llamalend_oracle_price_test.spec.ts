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

  let failThreshold: BigNumber;
  let price: BigNumber;

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
    failThreshold = await test.failurePrice();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if passing in message with high price', async () => {
    // first, set threshold lower than 4.569e16 in contract
    price = BigNumber.from('45690000000000000');
    console.log('fail threshold: ', failThreshold.toString());
    console.log('price to check: ', price.toString());

    await test.setMessageToCheck(
      price, //price
      BigNumber.from('1669858244'), //deadline
      BigNumber.from('27'), // v
      '0x57a44d4d5578295c0b40c13a6def46b2d28d5f1887c385bf38f1dbc29b64c8fc', //r
      '0x1b68ffc82e99e9a943e9cc1e1eaf3538726045976c9be0957aea87ecac2fe5ae' //s
    );
    expect(await test.checkTestPasses()).to.be.false;
  });
});
