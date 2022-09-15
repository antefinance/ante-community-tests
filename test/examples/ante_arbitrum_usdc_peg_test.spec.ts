import hre from 'hardhat';
const { waffle } = hre;

import { AnteArbitrumUSDCPegTest, AnteArbitrumUSDCPegTest__factory } from '../../typechain';
import { Contract, ContractFactory } from 'ethers';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteArbitrumUSDCPegTest', function () {
  //let test: AnteArbitrumUSDCPegTest;

  let globalSnapshotId: string;
  let factory: ContractFactory;
  let test: Contract;

  it('should return true', async function () {
    const provider = waffle.provider;
    console.log(provider);
    const factory = await hre.ethers.getContractFactory('AnteArbitrumUSDCPegTest');
    const test = await factory.deploy('0xff970a61a04b1ca14834a43f5de4533ebddb5cc8');

    expect(await test.checkTestPasses()).to.be.true;
  });

  //before(async () => {
  //  console.log("INIT");
  //  //globalSnapshotId = await evmSnapshot();

  //  const [deployer] = waffle.provider.getWallets();
  //  console.log(`Deployer ${deployer.address}`);
  //  console.log(waffle.provider);
  //  //const factory = (await hre.ethers.getContractFactory(
  //  //  'AnteArbitrumUSDCPegTest',
  //  //  //deployer
  //  //)) as AnteArbitrumUSDCPegTest__factory;
  //  factory = await hre.ethers.getContractFactory("AnteArbitrumUSDCPegTest");
  //  console.log("Factory done");
  //  test = await factory.deploy('0xff970a61a04b1ca14834a43f5de4533ebddb5cc8');
  //  await test.deployed();
  //  console.log("Test deployed");
  //});

  //after(async () => {
  //  console.log("Reverting");
  //  //await evmRevert(globalSnapshotId);
  //  console.log("Reverted");
  //});

  //it('should pass', async () => {
  //  console.log("Checking if test passes");
  //  expect(await test.checkTestPasses()).to.be.true;
  //});
});
