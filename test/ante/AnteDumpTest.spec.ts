import hre from 'hardhat';
const { waffle } = hre;

import { AnteDumpTest, AnteDumpTest__factory, BasicERC20, BasicERC20__factory } from '../../typechain';
import ERC20 from '../ABI/ERC20';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';
import { Contract } from 'ethers';

describe('AnteDumpTest', function () {
  let test: AnteDumpTest;

  let globalSnapshotId: string;

  const [owner, wallet1, wallet2] = waffle.provider.getWallets();

  let TEST_TOKEN: BasicERC20;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();
    
    const factory = (await hre.ethers.getContractFactory('AnteDumpTest', deployer)) as AnteDumpTest__factory;
    const testTokenFactory = (await hre.ethers.getContractFactory('BasicERC20', deployer)) as BasicERC20__factory;
    
    TEST_TOKEN = await testTokenFactory.connect(owner).deploy();
    await TEST_TOKEN.deployed();
    await TEST_TOKEN.connect(owner).mint('1000000000000000000000000', wallet1.address);

    test = await factory.deploy([TEST_TOKEN.address], [wallet1.address], '50');
    await test.deployed();

  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass then fail', async () => {
    await TEST_TOKEN.connect(wallet1).transfer(wallet2.address, '500000000000000000000000');

    expect((await test.checkTestPasses())).to.be.true;

    await TEST_TOKEN.connect(wallet1).transfer(wallet2.address, '1');

    expect((await test.checkTestPasses())).to.be.false;

  });
});
