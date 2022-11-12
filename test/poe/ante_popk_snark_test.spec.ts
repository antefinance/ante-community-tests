import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { 
    AntePoPKSnarkTest, 
    AntePoPKSnarkTest__factory,
    PoPKVerifier,
    PoPKVerifier__factory
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AntePoPKSnarkTest', function () {
  let test: AntePoPKSnarkTest;
  let verifier: PoPKVerifier;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Verifier
    const verifierFactory = (await hre.ethers.getContractFactory('PoPKVerifier', deployer)) as PoPKVerifier__factory;
    verifier = await verifierFactory.deploy();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoPKSnarkTest', deployer)) as AntePoPKSnarkTest__factory;
    test = await factory.deploy(verifier.address);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should still pass because input is wrong', async () => {
    const a = [BigNumber.from("0x018ad2b29c55d87137818e6e55b995888dcb3560d97af7d6da108f6b6976b8ce"), BigNumber.from("0x0f7feb172c1bf132874386374e312aebc18f068af5245fbcd80746da115191ed")];
    const b = [[BigNumber.from("0x18a438619ad71e95b2653ceeada073113e2c74791ef90a961268a39db7c74ba0"), BigNumber.from("0x1d353dedfd540410721b27f6a2e41a3c07665c92d78ceb6d6a5841353987c94c")],[BigNumber.from("0x079261ec8ffbc1361c3ed0a11fd72b7ad135d85b89de62a9888e6e5f309a0138"), BigNumber.from("0x2b1cad435383cc161ecf968a6fd7fc2857e34c93940b14ddb3b6558d41879615")]];
    const c = [BigNumber.from("0x232d8085feb603ba8ae3f8e15b06b98dfe1c448702a75e4992621121c750e413"), BigNumber.from("0x0ab2bbcc048b586c2405f061ae4b21b728e7544d372c381f5342d0721da6b99f")];
    const input = [BigNumber.from("0x10000000000000000000000066c777464c62f125760f80254257ed8dfccb2921")];
    await test.setCalldata(a as [BigNumber, BigNumber], b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], c as [BigNumber, BigNumber], input as [BigNumber]);
    expect(await test.checkTestPasses()).to.be.true;
  });
  
  it('should fail', async () => {
    const a = [BigNumber.from("0x018ad2b29c55d87137818e6e55b995888dcb3560d97af7d6da108f6b6976b8ce"), BigNumber.from("0x0f7feb172c1bf132874386374e312aebc18f068af5245fbcd80746da115191ed")];
    const b = [[BigNumber.from("0x18a438619ad71e95b2653ceeada073113e2c74791ef90a961268a39db7c74ba0"), BigNumber.from("0x1d353dedfd540410721b27f6a2e41a3c07665c92d78ceb6d6a5841353987c94c")],[BigNumber.from("0x079261ec8ffbc1361c3ed0a11fd72b7ad135d85b89de62a9888e6e5f309a0138"), BigNumber.from("0x2b1cad435383cc161ecf968a6fd7fc2857e34c93940b14ddb3b6558d41879615")]];
    const c = [BigNumber.from("0x232d8085feb603ba8ae3f8e15b06b98dfe1c448702a75e4992621121c750e413"), BigNumber.from("0x0ab2bbcc048b586c2405f061ae4b21b728e7544d372c381f5342d0721da6b99f")];
    const input = [BigNumber.from("0x00000000000000000000000066c777464c62f125760f80254257ed8dfccb2921")];
    await test.setCalldata(a as [BigNumber, BigNumber], b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], c as [BigNumber, BigNumber], input as [BigNumber]);
    expect(await test.checkTestPasses()).to.be.false;
  });
});
