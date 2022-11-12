import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { 
    AntePoMultiSigPKSnarkTest, 
    AntePoMultiSigPKSnarkTest__factory,
    PoMultiSigPKVerifier,
    PoMultiSigPKVerifier__factory
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AntePoMultiSigPKSnarkTest', function () {
  let test: AntePoMultiSigPKSnarkTest;
  let verifier: PoMultiSigPKVerifier;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Verifier
    const verifierFactory = (await hre.ethers.getContractFactory('PoMultiSigPKVerifier', deployer)) as PoMultiSigPKVerifier__factory;
    verifier = await verifierFactory.deploy();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoMultiSigPKSnarkTest', deployer)) as AntePoMultiSigPKSnarkTest__factory;
    test = await factory.deploy(verifier.address);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should still pass because first address in the input is incorrect', async () => {
    const a = [BigNumber.from("0x1552d8f5b0a39e47dc9b0261197dca74e53e7214a3812fa6c01d7b2f96e1ead6"), BigNumber.from("0x1ffe88ea388d4433fcc09ee2ddf79c6386a3e20d8c27059a996109a11e2dfba6")]
    const b = [[BigNumber.from("0x1219fe7679b6b7b4f288b2fccd7d8133e5ce966a9fa6ecf0d317d14b53d025c6"), BigNumber.from("0x05d5f4b5bb5bb516d96674436ec559772c578ad2594abb9cc54ca618d5efc72a")],[BigNumber.from("0x2d31af2db673f04ae367b8d866a8f93041f5370d84c64e8c43c180731db336db"), BigNumber.from("0x1bc7b79c5689021dade2d99a05cc97eb95d7a6e03901868bca8d55efe943f0f5")]]
    const c = [BigNumber.from("0x18aeca67ac574448e5d5c3ea648cb251d951bc3f34768a3df16b0e3660b75a03"), BigNumber.from("0x062f06861aa78ba44a41dd435df0f370364a3f80107d59249d83a0be42f7f0d6")]
    const input = [BigNumber.from("0x1d3af895fe557fd5504c536fffe695ac850ac003c78015ad85887bfe451ddf93"), BigNumber.from("0x10000000000000000000000066c777464c62f125760f80254257ed8dfccb2921"),BigNumber.from("0x00000000000000000000000009f1ef9171202a72d0854d421244b2361509dced"),BigNumber.from("0x0000000000000000000000003cf58a049f731e5f278304caf98b4699129e6a1d"),BigNumber.from("0x000000000000000000000000000000000000000000000000000000000000002a")]
    await test.setCalldata(
        a as [BigNumber, BigNumber], 
        b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], 
        c as [BigNumber, BigNumber], 
        input as [BigNumber, BigNumber, BigNumber, BigNumber, BigNumber]
    );
    expect(await test.checkTestPasses()).to.be.true;
  });
  
  it('should fail when proof of private key to address #1 is submitted', async () => {
    const a = [BigNumber.from("0x1552d8f5b0a39e47dc9b0261197dca74e53e7214a3812fa6c01d7b2f96e1ead6"), BigNumber.from("0x1ffe88ea388d4433fcc09ee2ddf79c6386a3e20d8c27059a996109a11e2dfba6")]
    const b = [[BigNumber.from("0x1219fe7679b6b7b4f288b2fccd7d8133e5ce966a9fa6ecf0d317d14b53d025c6"), BigNumber.from("0x05d5f4b5bb5bb516d96674436ec559772c578ad2594abb9cc54ca618d5efc72a")],[BigNumber.from("0x2d31af2db673f04ae367b8d866a8f93041f5370d84c64e8c43c180731db336db"), BigNumber.from("0x1bc7b79c5689021dade2d99a05cc97eb95d7a6e03901868bca8d55efe943f0f5")]]
    const c = [BigNumber.from("0x18aeca67ac574448e5d5c3ea648cb251d951bc3f34768a3df16b0e3660b75a03"), BigNumber.from("0x062f06861aa78ba44a41dd435df0f370364a3f80107d59249d83a0be42f7f0d6")]
    const input = [BigNumber.from("0x1d3af895fe557fd5504c536fffe695ac850ac003c78015ad85887bfe451ddf93"), BigNumber.from("0x00000000000000000000000066c777464c62f125760f80254257ed8dfccb2921"),BigNumber.from("0x00000000000000000000000009f1ef9171202a72d0854d421244b2361509dced"),BigNumber.from("0x0000000000000000000000003cf58a049f731e5f278304caf98b4699129e6a1d"),BigNumber.from("0x000000000000000000000000000000000000000000000000000000000000002a")]
    await test.setCalldata(
        a as [BigNumber, BigNumber], 
        b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], 
        c as [BigNumber, BigNumber], 
        input as [BigNumber, BigNumber, BigNumber, BigNumber, BigNumber]
    );
    expect(await test.checkTestPasses()).to.be.false;
  });

  it('should fail when proof of private key to address #2 is submitted', async () => {
    const a = [BigNumber.from("0x151f226a7cc7817a92faee602abbb3d797b19f0a90f42828cb488b6c5e25c476"), BigNumber.from("0x08818c203e6ae9124d3b703b878dcb1f72d4024607717cc13e3dd9d716f5e7e5")]
    const b = [[BigNumber.from("0x1cc5b72e5f3b4166b8888bca8a4773bb1c8ea309798e798cadb75733912cf928"), BigNumber.from("0x121bead2b2710aecff34ca76264bc0a85d16c7608875eec19a8ed466e875907d")],[BigNumber.from("0x223ef6ddda9a61d1595b8d2bb8a86e5cb9d34c730b6912826eaad6932c1ad3dd"), BigNumber.from("0x1307522b681f54e73e4f5579e978d10cf260d6e5954b9157cb9f70ee4e99eaad")]]
    const c = [BigNumber.from("0x1b224b2f8f3f38ac40950c869f48ac7b582692e042f5c26e6a6abad3b9c960b0"), BigNumber.from("0x258153ccccbf6aaeb094fca0ca15747349634f71a08e266c39f2bc37784a56c0")]
    const input = [BigNumber.from("0x098d355787181274a647054f5022da213fe21127a9383e9ae519d7577f192edc"), BigNumber.from("0x00000000000000000000000066c777464c62f125760f80254257ed8dfccb2921"),BigNumber.from("0x00000000000000000000000009f1ef9171202a72d0854d421244b2361509dced"),BigNumber.from("0x0000000000000000000000003cf58a049f731e5f278304caf98b4699129e6a1d"),BigNumber.from("0x000000000000000000000000000000000000000000000000000000000000002a")]
    await test.setCalldata(
        a as [BigNumber, BigNumber], 
        b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], 
        c as [BigNumber, BigNumber], 
        input as [BigNumber, BigNumber, BigNumber, BigNumber, BigNumber]
    );
    expect(await test.checkTestPasses()).to.be.false;
  });
  
  it('should fail when proof of private key to address #3 is submitted', async () => {
    const a = [BigNumber.from("0x0feaf2db9e569c8ce246f95ea7026b9451f7277df6ee9bed01b31092875dab1f"), BigNumber.from("0x0fdcfcd3898d5080ce9d5f442bc135c636b98a3cff3150069fc7b9739b51c698")]
    const b = [[BigNumber.from("0x21d9e23ace5b00282cb79d7f689ef9f1c5a3989b802d87dcb04ef9dce6580f5f"), BigNumber.from("0x24a56d776b7af15625572df18841975d2fcd0b09b2d1418cc141d91d5642fa7d")],[BigNumber.from("0x1c9f17ba267e2c7a33a369e1d6992f2b1373b5a2424e40308488124c7141d956"), BigNumber.from("0x2689817d6c6821abffc84a0e22d02bdef99be519ebbfff3c1a86a0e899c114f7")]]
    const c = [BigNumber.from("0x2de096e79d92347ae410a48616c45af95d7bf2efdd8a97d17b203f91452250ba"), BigNumber.from("0x071bd64ee53b07a6c2bbcf63d806c6f6b41db9fa996d442b3970ac6c5aa5dba4")]
    const input = [BigNumber.from("0x0f8be8bf8e5fa2df949a1c6bfa54749790927f135654edc2de537c2d17d8e30e"), BigNumber.from("0x00000000000000000000000066c777464c62f125760f80254257ed8dfccb2921"),BigNumber.from("0x00000000000000000000000009f1ef9171202a72d0854d421244b2361509dced"),BigNumber.from("0x0000000000000000000000003cf58a049f731e5f278304caf98b4699129e6a1d"),BigNumber.from("0x000000000000000000000000000000000000000000000000000000000000002a")]
    await test.setCalldata(
        a as [BigNumber, BigNumber], 
        b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], 
        c as [BigNumber, BigNumber], 
        input as [BigNumber, BigNumber, BigNumber, BigNumber, BigNumber]
    );
    expect(await test.checkTestPasses()).to.be.false;
  });
});
