import hre from 'hardhat';
import chalk from 'chalk';

const main = async () => {
  const [deployer] = await hre.ethers.getSigners();

  const poolFactoryAddress = '0xa03492A9A663F04c51684A3c172FC9c4D7E02eDc';
  // name of the contract for Ante Test
  const testName = 'AnteOpynPlungeTest';
  // array of constructor arguments for Ante Test
  const args = [] as const;

  console.log(
    'Deploying Ante Test',
    chalk.cyan(testName),
    'from deployer address',
    chalk.cyan(deployer.address),
    'with constructor arguments',
    chalk.magenta(args.toString()),
    'on network',
    chalk.magenta(hre.network.name)
  );

  const testFactory = await hre.ethers.getContractFactory(testName);
  const test = await testFactory.connect(deployer).deploy(...args);
  console.log('Ante Test deploying to ', chalk.cyan(test.address));
  await test.deployed();
  console.log('Ante test successfully deployed!');

  console.log('Connecting to pool factory at ', chalk.magenta(poolFactoryAddress));
  const poolFactory = await hre.ethers.getContractAt(
    'contracts/libraries/ante-v05-avax/AntePoolFactory.sol:AntePoolFactory',
    poolFactoryAddress
  );
  const tx = await poolFactory.createPool(test.address);
  const receipt = await tx.wait();
  let poolAddress = receipt.events;

  console.log('TX Hash: ', chalk.cyan(receipt.transactionHash), ' completed');
  if (poolAddress) {
    console.log('Pool deployed to ', poolAddress);
  } else {
    console.log('Check TX, no createPool event recorded');
  }
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
