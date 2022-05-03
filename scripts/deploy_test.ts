import hre from 'hardhat';
import chalk from 'chalk';

const main = async () => {
  const [deployer] = await hre.ethers.getSigners();

  // name of the contract for Ante Test
  const testName = 'AnteEthDevRugTest';
  // array of constructor arguments for Ante Test
  const args = ['0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae'] as const;

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
  console.log('Visit', chalk.cyan('app.ante.finance/#/create-pool'), 'to deploy an Ante Pool for this test');
  console.log(
    'Check out our docs (',
    chalk.magenta('docs.ante.finance'),
    ') for information on how to get your test verified and join our Discord (',
    chalk.magenta('discord.gg/yaJthzNdNG'),
    ') to connect with likeminded developers!'
  );
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
