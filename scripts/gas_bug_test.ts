import hre from 'hardhat';

import { evmMineBlocks } from '../test/helpers';
import { Contract } from 'ethers';
import {
  AnteYetiFinanceSupplyTest__factory, // REPLACE THIS WITH YOUR TEST FACTORY
  AntePoolFactory__factory,
} from '../typechain';

const { web3 } = hre;

const main = async () => {
  const [deployer] = await hre.ethers.getSigners();

  // Deploy test
  const testFactory = (await hre.ethers.getContractFactory(
    'AnteYetiFinanceSupplyTest', // UPDATE THIS WITH YOUR TEST INFORMATION
    deployer
  )) as AnteYetiFinanceSupplyTest__factory; // UPDATE THIS WITH YOUR TEST INFORMATION
  const test = await testFactory.deploy(); // If your test takes any arguments, add them in
  await test.deployed();
  var testName = await test.testName();
  console.log('\nChecking Ante Test:', testName);
  console.log('Test deployed');

  // deploy pool factory
  const antePoolFactory = (await hre.ethers.getContractFactory(
    'contracts/libraries/ante-v05-core/AntePoolFactory.sol:AntePoolFactory',
    deployer
  )) as AntePoolFactory__factory;
  const poolFactory = await antePoolFactory.deploy();
  await poolFactory.deployed();

  // Deploy AntePool
  var tx = await poolFactory.createPool(test.address);
  var receipt = await tx.wait();
  // @ts-ignore
  const poolAddress = receipt.events[receipt.events.length - 1].args['testPool'];
  const pool = await hre.ethers.getContractAt('contracts/libraries/ante-v05-core/AntePool.sol:AntePool', poolAddress);
  console.log('pool deployed');

  // Deploy Mock AntePoolFactory so we can deploy the version of AntePool
  // without the pre-external call stuff in checkTest
  // essentially https://github.com/antefinance/ante-v0-core/blob/fdd0d8d68a5697415cde511aa5dc98c469871bb7/contracts/AntePool.sol
  // but minus lines 293–301
  const mockAntePoolFactory = (await hre.ethers.getContractFactory(
    'contracts/libraries/ante-gas-mock/AntePoolFactory.sol:AntePoolFactory',
    deployer
  )) as AntePoolFactory__factory;
  const mockPoolFactory = await mockAntePoolFactory.deploy();
  await mockPoolFactory.deployed();
  console.log('mock factory deployed');

  // Deploy Mock AntePool (missing the pre-external call stuff in checkTest)
  tx = await mockPoolFactory.createPool(test.address);
  receipt = await tx.wait();
  // @ts-ignore
  const mockPoolAddress = receipt.events[receipt.events.length - 1].args['testPool'];
  const mockPool = await hre.ethers.getContractAt(
    'contracts/libraries/ante-gas-mock/AntePool.sol:AntePool',
    mockPoolAddress
  );
  console.log('mock pool deployed');

  // Challenge pools and progress 12 blocks so we are eligible to checkTest
  await pool.stake(true, { value: hre.ethers.utils.parseEther('1') });
  await mockPool.stake(true, { value: hre.ethers.utils.parseEther('1') });
  await evmMineBlocks(12);
  console.log('setup complete');

  // Get cost of external call to AnteTest.checkTestPasses()
  var testGas = await web3.eth.estimateGas(
    {
      from: deployer.address,
      to: test.address,
      data: web3.eth.abi.encodeFunctionSignature('checkTestPasses()'),
    },
    function (err: any, estimatedGas: any) {
      if (err) console.log(err);
    }
  );
  console.log('AnteTest.checkTestPasses():', testGas);

  // Get cost of entire AntePool.checkTest() call
  var poolGas = await web3.eth.estimateGas(
    {
      from: deployer.address,
      to: poolAddress,
      data: web3.eth.abi.encodeFunctionSignature('checkTest()'),
    },
    function (err: any, estimatedGas: any) {
      if (err) console.log(err);
    }
  );
  console.log('AntePool.checkTest():      ', poolGas);

  // Get cost of MockAntePool.checkTest() call
  var mockPoolGas = await web3.eth.estimateGas(
    {
      from: deployer.address,
      to: mockPoolAddress,
      data: web3.eth.abi.encodeFunctionSignature('checkTest()'),
    },
    function (err: any, estimatedGas: any) {
      if (err) console.log(err);
    }
  );
  console.log('MockAntePool.checkTest():  ', mockPoolGas, '\n');

  console.log('Implied pre-call gas:      ', poolGas - mockPoolGas);
  console.log('External call gas:         ', testGas);
  console.log('Implied post-call gas:     ', mockPoolGas - testGas);
  console.log('Gas ratio (>63 = REKT):    ', testGas / (mockPoolGas - testGas));
  console.log('Safety factor:             ', (63 * (mockPoolGas - testGas)) / testGas);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
