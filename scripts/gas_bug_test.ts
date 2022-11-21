import hre from 'hardhat';

import { evmMineBlocks } from '../test/helpers';
import {
  AnteOKXEthReservesTest__factory, // REPLACE THIS WITH YOUR TEST FACTORY
  AntePoolFactory__factory,
} from '../typechain';

const { web3 } = hre;

const main = async () => {
  const [deployer] = await hre.ethers.getSigners();

  // Deploy Ante Test
  const testFactory = (await hre.ethers.getContractFactory(
    'AnteOKXEthReservesTest', // UPDATE THIS WITH YOUR TEST INFORMATION
    deployer
  )) as AnteOKXEthReservesTest__factory; // UPDATE THIS WITH YOUR TEST INFORMATION
  const test = await testFactory.deploy(); // If your test takes any arguments, add them in
  await test.deployed();
  var testName = await test.testName();
  console.log('\nChecking Ante Test:', testName);

  // Deploy mock AntePoolFactory so we can deploy the version of AntePool
  // without the pre-external call stuff in checkTest and always failing
  const mockAntePoolFactory = (await hre.ethers.getContractFactory(
    'contracts/libraries/ante-gas-mock/AntePoolFactory.sol:AntePoolFactory',
    deployer
  )) as AntePoolFactory__factory;
  const mockPoolFactory = await mockAntePoolFactory.deploy();
  await mockPoolFactory.deployed();

  // Deploy mock AntePool (missing the pre-external call stuff in checkTest
  // and always follows the failure path so we get the correct gas usage)
  var tx = await mockPoolFactory.createPool(test.address);
  var receipt = await tx.wait();
  // @ts-ignore
  const mockPoolAddress = receipt.events[receipt.events.length - 1].args['testPool'];
  const mockPool = await hre.ethers.getContractAt(
    'contracts/libraries/ante-gas-mock/AntePool.sol:AntePool',
    mockPoolAddress
  );

  // Challenge pool and progress 12 blocks so we are eligible to checkTest
  await mockPool.stake(true, { value: hre.ethers.utils.parseEther('1') });
  await evmMineBlocks(12);

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
