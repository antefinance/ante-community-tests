import { HardhatRuntimeEnvironment } from "hardhat/types";
import chalk from 'chalk';
import { getZksyncDeployer } from "../test/helpers";

export default async function (hre: HardhatRuntimeEnvironment) {
  try {
    // name of the contract for Ante Test
    const testName = 'AnteWETH9TestZkSync';
    // array of constructor arguments for Ante Test
    const args = ['0x5AEa5775959fBC2557Cc8789bC1bf90A239D9a91'];

    // Create deployer object
    const deployer = await getZksyncDeployer(hre);

    console.log(
      'Deploying Ante Test',
      chalk.cyan(testName),
      'from deployer address',
      chalk.cyan(deployer.zkWallet.address),
      'with constructor arguments',
      chalk.magenta(args.toString()),
      'on network',
      chalk.magenta(hre.network.name)
    );

    // Load contract
    const artifact = await deployer.loadArtifact(testName);

    const testContract = await deployer.deploy(artifact, args);

    console.log('Ante Test deploying to ', chalk.cyan(testContract.address));

    await testContract.deployed();

    console.log('Ante test successfully deployed!');
    console.log('Visit', chalk.cyan('app.ante.finance/create-pool'), 'to deploy an Ante Pool for this test');
    console.log(
      'Check out our docs (',
      chalk.magenta('docs.ante.finance'),
      ') for information on how to get your test verified and join our Discord (',
      chalk.magenta('discord.gg/yaJthzNdNG'),
      ') to connect with likeminded developers!'
    );
  } catch (error) {
    console.error(error);
  }
}
